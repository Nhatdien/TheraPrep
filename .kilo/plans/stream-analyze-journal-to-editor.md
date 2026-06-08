# Plan: Stream Analyze-Journal AI Response to User Editor

## Context

The `analyze-journal` feature generates an AI follow-up question after the user writes a journal entry. Currently:
- Frontend calls `POST /api/analyze-journal` via `AIService.analyzeJournal()` and waits for the full JSON response.
- Backend (`AIProcessor.generate_journal_question()`) runs crisis detection + RAG retrieval in parallel, then calls the LLM with `.invoke()` (blocking), and returns the complete question.
- The full question is inserted into the TipTap editor in one shot from three call sites:
  - `pages/journaling/index.vue`
  - `pages/journaling/[id].vue`
  - `components/Slide/JournalPrompt.vue`

Goal: stream the LLM-generated question into the TipTap editor token-by-token so the user sees text appear in real time.

## Important Constraints

1. **Crisis detection must remain blocking and run first.** If a crisis is detected, no question text should be streamed at all.
2. **RAG retrieval (past journals + memories)** is also blocking and should complete before streaming starts.
3. The `.ai-suggestion` CSS class is used for AI-generated paragraphs and is intentionally excluded from journal card previews (`utils/journal.ts`). New streamed paragraphs must keep this class.
4. All three call sites share nearly identical `handleGoDeeper` logic; the streaming logic should be DRY.

## Architecture Decision

### Protocol: NDJSON over HTTP (`fetch` + `ReadableStream`)
- FastAPI `StreamingResponse` yields newline-delimited JSON objects.
- Frontend reads the stream via `response.body.getReader()` + `TextDecoder`, splits on `\n`, and parses each JSON line.
- No SSE/EventSource needed (avoids POST limitation complexity).

### Stream Event Schema
```ndjson
{"type":"metadata","crisis_detected":false}
{"type":"token","content":"What"}
{"type":"token","content":" made"}
{"type":"token","content":" you"}
{"type":"token","content":" feel"}
{"type":"token","content":" this"}
{"type":"token","content":" way"}
{"type":"token","content":"?"}
{"type":"done"}
```
Crisis path:
```ndjson
{"type":"metadata","crisis_detected":true,"crisis_message":"..."}
{"type":"done"}
```

### Editor Insertion Strategy
1. Insert an empty TipTap paragraph with class `ai-suggestion` (and an optional `data-stream-id` attribute) at the editor end.
2. Track the ProseMirror position at the end of that paragraph.
3. On each token chunk, use `editor.commands.insertText(chunk, { at: position })` (or the equivalent ProseMirror `tr.insertText`) to append text, then advance the position by `chunk.length`.
4. After the stream completes (or errors), insert an empty paragraph after the AI suggestion so the user can continue typing.

This avoids re-rendering the whole node on each chunk and is robust as long as the user does not delete the AI paragraph while streaming (the UI already sets `isGeneratingQuestion = true`, which disables the "Go Deeper" button but does not lock the editor).

## Implementation Steps

### 1. Backend — Add Streaming Method to AIProcessor
**File:** `tranquara_ai_service/service/ai_service_processor.py`

- Add `generate_journal_question_stream()` as an **async generator** (`async def ...`).
- Re-use the existing blocking logic exactly:
  1. Run `check_crisis`, `_retrieve_past_journals`, `_retrieve_user_memories` in parallel via `ThreadPoolExecutor`.
  2. If `crisis_result["is_crisis"]`: `yield` the crisis metadata and return.
  3. If safe: call `self.model.astream(messages)` (async streaming). Note: may require `streaming=True` in the `ChatGoogleGenerativeAI` constructor.
  4. `async for chunk in stream: yield chunk.content`
- Keep the existing `generate_journal_question()` untouched for backward compatibility.

### 2. Backend — Add Streaming Endpoint
**File:** `tranquara_ai_service/router/analyze.py`

- Add `POST /api/analyze-journal/stream`.
- Use `fastapi.responses.StreamingResponse` with `media_type="application/x-ndjson"`.
- The route handler:
  1. Instantiates `AIProcessor`.
  2. Runs `generate_journal_question_stream()`.
  3. Yields JSON-encoded events:
     - First event: `{"type":"metadata","crisis_detected":...}`
     - Subsequent events: `{"type":"token","content":"..."}`
     - Final event: `{"type":"done"}`
- Wrap in try/except; on exception yield `{"type":"error","message":"..."}` before closing.

### 3. Frontend SDK — Add `analyzeJournalStream()`
**File:** `tranquara_frontend/stores/ai_service.ts`

- Add new method `analyzeJournalStream(params): AsyncGenerator<StreamEvent>`.
- Use native `fetch` (not `this.fetch`) because the base `fetch` consumes the full response body as JSON/text.
- Set headers: `Content-Type: application/json`, `Authorization`, `Accept-Language`.
- Read `response.body.getReader()` in a loop, decode with `TextDecoder`, split buffer on `\n`, parse JSON lines.
- `yield` each parsed event object.
- Handle HTTP errors (non-200 status) by throwing before streaming starts.
- Provide an `AbortController` signal so callers can cancel the stream.

**Types to add (can be inline or in a shared types file):**
```ts
type StreamEvent =
  | { type: 'metadata'; crisis_detected: boolean; crisis_message?: string }
  | { type: 'token'; content: string }
  | { type: 'done' }
  | { type: 'error'; message: string };
```

### 4. Frontend — Create Reusable `streamToEditor` Helper
**File:** `tranquara_frontend/utils/journal.ts` (or a new composable)

```ts
export async function streamToEditor(
  editor: Editor,
  stream: AsyncGenerator<StreamEvent>,
  options?: { onCrisis?: () => void; onError?: (err: Error) => void; onDone?: () => void }
): Promise<void>
```

Implementation:
1. Generate a unique `streamId` (e.g., `ai-stream-${Date.now()}`).
2. Insert empty paragraph:
   ```ts
   editor.chain().focus('end')
     .insertContent(`<p class="ai-suggestion text-muted italic" data-stream-id="${streamId}"></p>`)
     .insertContent('<p></p>')
     .run();
   ```
3. Helper `findStreamPos(editor, streamId)` walks `editor.state.doc.descendants` to locate the paragraph and returns the ProseMirror position at the end of its content (`pos + 1 + node.content.size`).
4. Iterate the stream:
   - `metadata` + `crisis_detected`: call `options.onCrisis()`, delete the AI paragraph (find by `streamId`, `deleteRange`), return.
   - `token`: find current end position, `editor.commands.insertText(event.content, { at: position })`, advance tracked position.
   - `done`: call `options.onDone()`.
   - `error`: call `options.onError()`, optionally delete the AI paragraph.
5. If the loop exits without `done` (e.g., network drop), treat as error.

### 5. Frontend — Refactor Call Sites to Use Streaming
Update all three locations to call `streamToEditor` instead of awaiting the full response.

#### a) `pages/journaling/index.vue`
- In `handleGoDeeper`, after client-side crisis check:
  ```ts
  const stream = sdk.analyzeJournalStream({ ...same params... });
  await streamToEditor(editorRef.value.editor, stream, {
    onCrisis: () => { if (!clientCrisisDetected) showCrisisModal(); autoSaveStatus.value = 'ready'; },
    onError: (err) => { console.error(err); autoSaveStatus.value = 'errorGenerating'; /* optional fallback */ },
    onDone: () => { autoSaveStatus.value = 'questionAdded'; setTimeout(() => autoSaveStatus.value = 'ready', 2000); }
  });
  ```
- Set `isGeneratingQuestion.value = true` before streaming and `false` in `onDone` / `onError`.

#### b) `pages/journaling/[id].vue`
- Same pattern as above.
- Re-use the existing `insertQuestionToEditor` helper as a fallback on error (insert the fallback question text).

#### c) `components/Slide/JournalPrompt.vue`
- Same pattern, using `editor.value.editor`.

### 6. Cleanup & Edge Cases
- **Abort/cancel**: If the user navigates away while streaming, the stream reader should be closed and the `AbortController` aborted. Use `onUnmounted` or a local abort signal.
- **Double crisis modal**: If `clientCrisisDetected` is already true, the `onCrisis` callback should not call `showCrisisModal()` again (already handled by the existing code).
- **Empty stream**: If the backend yields no tokens after metadata, the empty AI paragraph should be removed.
- **Existing `.ai-suggestion` nodes**: If the user clicks "Go Deeper" multiple times (after the first finishes), each click inserts a new AI paragraph. This is acceptable and matches current behavior.

## Files to Modify

| File | Change |
|------|--------|
| `tranquara_ai_service/service/ai_service_processor.py` | Add `generate_journal_question_stream()` async generator |
| `tranquara_ai_service/router/analyze.py` | Add `/api/analyze-journal/stream` `StreamingResponse` endpoint |
| `tranquara_frontend/stores/ai_service.ts` | Add `analyzeJournalStream()` method |
| `tranquara_frontend/utils/journal.ts` | Add `streamToEditor()` helper |
| `tranquara_frontend/pages/journaling/index.vue` | Refactor `handleGoDeeper` to stream |
| `tranquara_frontend/pages/journaling/[id].vue` | Refactor `handleGoDeeper` to stream |
| `tranquara_frontend/components/Slide/JournalPrompt.vue` | Refactor `handleGoDeeper` to stream |

## Testing Strategy (Manual / Validation Checklist)

1. Call "Go Deeper" on safe content → tokens appear progressively in the editor.
2. Call "Go Deeper" on crisis content → no tokens appear; crisis modal shows.
3. Call "Go Deeper" then navigate away before stream ends → no errors, stream aborts cleanly.
4. Verify `.ai-suggestion` paragraphs still do not appear in journal card previews.
5. Verify fallback question still works when backend returns an error event.
6. Verify existing non-streaming endpoint (`/api/analyze-journal`) still works (backward compat).

## Open Questions

- Should we keep the old non-streaming endpoint entirely untouched, or mark it deprecated? (Plan keeps it untouched for safety.)
- Should the streamed paragraph include a visual "typing" indicator (e.g., pulsing cursor) while tokens are arriving? (Out of scope for this refactor; can be added later via CSS.)
