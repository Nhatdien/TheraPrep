import type { StreamEvent } from '~/stores/ai_service';

export const generateJournalHtml = (questionAnswer: { [key: string]: string }): string => {
  let result = ""

  for (const key of Object.keys(questionAnswer)) {
    // Skip metadata entries (keys that are metadata, not actual questions)
    if (key.includes('mood_score') || key.includes('_score') || key.match(/^[a-z_]+_\d+$/)) {
      continue
    }

    const notEmptyAnswer = (questionAnswer[key] !== "") && (questionAnswer[key] !== "<p></p>")
    // Detect sleep check entries: answer is a bare integer/number string (0–100)
    const isSleepNumeric = /^\d+(\.\d+)?$/.test((questionAnswer[key] || '').trim())
    const sleepAttr = isSleepNumeric ? ' data-sleep-entry="true"' : ''
    result += notEmptyAnswer ? `<div class="mb-4 journal-entry"${sleepAttr}><h3 class="journal-question">${key}</h3><p class="journal-answer">${questionAnswer[key]}</p></div>` : ""
  }

  return result
}

type parseResult = {
  [key: string]: string
}

export const parseJournalHtml = (
  html: string
): parseResult => {
  const parser = new DOMParser();
  const doc = parser.parseFromString(html, "text/html");

  const result: parseResult = {};

  doc.querySelectorAll(".journal-entry").forEach((block) => {
    const question =
      block.querySelector(".journal-question")?.textContent?.trim() ?? "";

    const answerMarker = block.querySelector(".journal-answer");
    let answerHtml = "";

    if (answerMarker) {
      // collect all siblings after .journal-answer
      let node = answerMarker.nextSibling;
      while (node) {
        if (node.nodeType === Node.ELEMENT_NODE) {
          answerHtml += (node as HTMLElement).outerHTML;
        } else if (node.nodeType === Node.TEXT_NODE) {
          answerHtml += node.textContent;
        }
        node = node.nextSibling;
      }
    }

    result[question] = answerHtml.trim()
  });

  return result;
};

export const isEmptyJournal = (journalContent: {[key: string]: string}) => {
  return Object.keys(journalContent).length < 1
}

/**
 * Extract the first complete Q&A pair from a journal HTML string for card previews.
 *
 * Handles three content formats:
 *   1. Structured Q&A (from generateJournalHtml) — has .journal-entry / .journal-question / .journal-answer classes
 *   2. Free-form TipTap HTML — first <h3> is the question, next non-empty <p> is the answer
 *      (AI follow-up .ai-suggestion paragraphs are intentionally SKIPPED — not the original question)
 *   3. Fallback — join all block text with spaces
 *
 * Returns an HTML snippet or plain text suitable for v-html rendering in card previews.
 */
export const getJournalContentPreview = (content: string): string => {
  if (!content) return '';

  if (typeof DOMParser !== 'undefined') {
    try {
      const parser = new DOMParser();
      const doc = parser.parseFromString(content, 'text/html');

      // Strip sleep entries — they already have a dedicated tag in the card UI
      doc.querySelectorAll('[data-sleep-entry="true"]').forEach((el) => el.remove());

      // ── 1. Structured format (.journal-entry/.journal-question/.journal-answer) ──
      const firstEntry = doc.querySelector('.journal-entry');
      if (firstEntry) {
        const question = firstEntry.querySelector('.journal-question')?.textContent?.trim() ?? '';
        const answer = firstEntry.querySelector('.journal-answer')?.textContent?.trim() ?? '';
        if (question && answer) {
          const truncated = answer.length > 120 ? answer.substring(0, 120) + '…' : answer;
          return `<p class="text-xs font-medium text-highlighted mb-1">${question}</p><p class="text-sm text-muted line-clamp-3">${truncated}</p>`;
        }
        if (answer) {
          const truncated = answer.length > 150 ? answer.substring(0, 150) + '…' : answer;
          return `<p class="text-sm text-muted">${truncated}</p>`;
        }
      }

      // ── 2. Free-form TipTap HTML — <h3> is the question, next real <p> is the answer ──
      // AI follow-up questions (.ai-suggestion) are NOT the original question and must be skipped.
      const firstHeading = doc.body.querySelector('h1, h2, h3, h4, h5, h6');
      if (firstHeading) {
        const question = firstHeading.textContent?.trim() ?? '';
        // Walk forward siblings looking for first non-empty <p> that is NOT an AI suggestion
        let sibling = firstHeading.nextElementSibling as Element | null;
        while (sibling) {
          if (sibling.matches('p') && !sibling.classList.contains('ai-suggestion')) {
            const answer = sibling.textContent?.trim() ?? '';
            if (answer) {
              const truncated = answer.length > 120 ? answer.substring(0, 120) + '…' : answer;
              if (question) {
                return `<p class="text-xs font-medium text-highlighted mb-1">${question}</p><p class="text-sm text-muted line-clamp-3">${truncated}</p>`;
              }
              return `<p class="text-sm text-muted line-clamp-3">${truncated}</p>`;
            }
          }
          sibling = sibling.nextElementSibling;
        }
        // Heading exists but no following answer — just show the heading
        if (question) return `<p class="text-sm text-muted">${question}</p>`;
      }

      // ── 3. No heading — collect non-AI-suggestion block text joined with spaces ──
      const blockEls = Array.from(doc.body.querySelectorAll('p:not(.ai-suggestion), li'));
      const plainText = blockEls
        .map(el => el.textContent?.trim())
        .filter(Boolean)
        .join(' ') || (doc.body.textContent?.trim() ?? '');

      return plainText.length > 150 ? plainText.substring(0, 150) + '…' : plainText;
    } catch {
      // fall through to regex fallback
    }
  }

  // ── Server-side / parsing failure: regex extraction ──
  // Strip sleep entry blocks so they don't show in card previews
  const contentWithoutSleep = content.replace(/<div[^>]*data-sleep-entry="true"[^>]*>[\s\S]*?<\/div>/gi, '');
  const qMatch = contentWithoutSleep.match(/<h3[^>]*class="journal-question"[^>]*>(.*?)<\/h3>/);
  const aMatch = contentWithoutSleep.match(/<p[^>]*class="journal-answer"[^>]*>([\s\S]*?)<\/p>/);
  if (qMatch && aMatch) {
    const q = qMatch[1].replace(/<[^>]*>/g, '').trim();
    const a = aMatch[1].replace(/<[^>]*>/g, '').trim();
    if (q && a) {
      const truncated = a.length > 120 ? a.substring(0, 120) + '…' : a;
      return `<p class="text-xs font-medium text-highlighted mb-1">${q}</p><p class="text-sm text-muted">${truncated}</p>`;
    }
  }

  // Last resort: strip all tags and join with spaces using a simple split on tags
  const stripped = content.replace(/<\/(p|h[1-6]|li|div)\>/gi, ' ').replace(/<[^>]*>/g, '').replace(/\s+/g, ' ').trim();
  return stripped.length > 150 ? stripped.substring(0, 150) + '…' : stripped;
};

// ─── Stream-to-Editor helper ────────────────────────────────────────────────

function findStreamNodePos(editor: any, streamId: string): number | null {
  let foundPos: number | null = null;
  editor.state.doc.descendants((node: any, pos: number) => {
    if (foundPos !== null) return false;
    if (node.type.name === 'paragraph' && node.attrs['data-stream-id'] === streamId) {
      foundPos = pos + 1 + node.content.size;
      return false;
    }
  });
  return foundPos;
}

function deleteStreamNode(editor: any, streamId: string): void {
  editor.state.doc.descendants((node: any, pos: number) => {
    if (node.type.name === 'paragraph' && node.attrs['data-stream-id'] === streamId) {
      const endPos = pos + node.nodeSize;
      editor.chain().focus().deleteRange({ from: pos, to: endPos }).run();
      return false;
    }
  });
}

export async function streamToEditor(
  editor: any,
  stream: AsyncGenerator<StreamEvent>,
  options?: {
    onCrisis?: () => void;
    onError?: (err: Error) => void;
    onDone?: () => void;
  }
): Promise<void> {
  const streamId = `ai-stream-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;

  // Insert empty AI paragraph + trailing empty paragraph
  editor
    .chain()
    .focus('end')
    .insertContent(`<p class="ai-suggestion text-muted italic" data-stream-id="${streamId}"></p>`)
    .insertContent('<p></p>')
    .run();

  let receivedToken = false;
  let completed = false;

  try {
    for await (const event of stream) {
      if (event.type === 'metadata') {
        if (event.crisis_detected) {
          deleteStreamNode(editor, streamId);
          options?.onCrisis?.();
          return;
        }
        continue;
      }

      if (event.type === 'token') {
        const position = findStreamNodePos(editor, streamId);
        if (position !== null) {
          editor.commands.insertText(event.content, { at: position });
          receivedToken = true;
        }
        continue;
      }

      if (event.type === 'done') {
        completed = true;
        options?.onDone?.();
        return;
      }

      if (event.type === 'error') {
        throw new Error(event.message);
      }
    }

    // Loop exited without 'done' (e.g., network drop)
    if (!completed) {
      throw new Error('Stream ended unexpectedly');
    }
  } catch (err) {
    const error = err instanceof Error ? err : new Error(String(err));
    if (!receivedToken) {
      deleteStreamNode(editor, streamId);
    }
    options?.onError?.(error);
  }
}