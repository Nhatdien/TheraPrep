import { Base } from "./base";

export type StreamEvent =
  | { type: 'metadata'; crisis_detected: boolean; crisis_message?: string }
  | { type: 'token'; content: string }
  | { type: 'done' }
  | { type: 'error'; message: string };

export class AIService extends Base {
  /**
   * Analyze journal content and get a follow-up question from AI.
   * Enhanced with RAG: AI service queries user's past journals from Qdrant
   * to generate more personalized, pattern-aware follow-up questions.
   */
  async analyzeJournal(params: {
    user_id: string;              // Required: user UUID for Qdrant filtering
    content: string;
    mood_score: number;
    slide_prompt?: string;
    slide_group_context?: any;    // Full slide group data
    current_slide_id?: string;    // Current slide ID
    collection_title?: string;    // Collection name
    direction?: 'why' | 'emotions' | 'patterns' | 'challenge' | 'growth';
    your_story?: string;          // User's personal context from settings
    app_language?: string;        // User's app language setting ('en' | 'vi')
  }): Promise<{
    question: string | null;
    crisis_detected: boolean;
    crisis_message: string | null;
  }> {
    const url = `${this.config.websocket_url || 'http://localhost:8000'}/api/analyze-journal`;

    const response = await this.fetch<{
      question: string | null;
      crisis_detected: boolean;
      crisis_message: string | null;
    }>(url, {
      method: "POST",
      body: JSON.stringify(params),
    });

    return response;
  }

  /**
   * Stream analyze-journal tokens via NDJSON.
   * Uses native fetch (not this.fetch) because the base fetch consumes
   * the full response body as JSON/text.
   */
  async *analyzeJournalStream(params: {
    user_id: string;
    content: string;
    mood_score: number;
    slide_prompt?: string;
    slide_group_context?: any;
    current_slide_id?: string;
    collection_title?: string;
    direction?: 'why' | 'emotions' | 'patterns' | 'challenge' | 'growth';
    your_story?: string;
    app_language?: string;
  }, abortSignal?: AbortSignal): AsyncGenerator<StreamEvent> {
    const url = `${this.config.websocket_url || 'http://localhost:8000'}/api/analyze-journal/stream`;

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': this.config.access_token ? `Bearer ${this.config.access_token}` : '',
        'Accept-Language': this.config.locale || 'en',
      },
      body: JSON.stringify(params),
      signal: abortSignal,
    });

    if (!response.ok) {
      const text = await response.text().catch(() => '');
      throw new Error(`HTTP ${response.status}: ${text || response.statusText}`);
    }

    if (!response.body) {
      throw new Error('Response body is null');
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let buffer = '';

    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const line of lines) {
          const trimmed = line.trim();
          if (!trimmed) continue;
          try {
            const event = JSON.parse(trimmed) as StreamEvent;
            yield event;
            if (event.type === 'done' || event.type === 'error') {
              return;
            }
          } catch {
            // Ignore malformed lines
          }
        }
      }

      // Process any remaining buffered data
      if (buffer.trim()) {
        try {
          const event = JSON.parse(buffer.trim()) as StreamEvent;
          yield event;
        } catch {
          // Ignore malformed final line
        }
      }
    } finally {
      reader.releaseLock();
    }
  }
}
