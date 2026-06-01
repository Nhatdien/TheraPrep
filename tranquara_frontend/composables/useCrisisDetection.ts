/**
 * Crisis Detection Composable
 * 
 * Detects potential self-harm / suicidal content in journal text
 * and shows crisis hotline modal before proceeding.
 * 
 * Uses Nuxt's useState for shared state — so the modal state is
 * consistent across all components that call this composable.
 * 
 * Hotlines:
 * - Ngày Mai: 096 306 1414 (suicide prevention, Vietnam)
 * - National Hotline: 111 (free, 24/7, Vietnam)
 */

const CRISIS_KEYWORDS_VI = [
  'tự tử', 'muốn chết', 'không muốn sống', 'chết đi', 'kết thúc cuộc đời',
  'không còn lý do để sống', 'sống không còn ý nghĩa', 'muốn biến mất',
  'tự hại', 'cắt tay', 'làm đau bản thân',
  'tự kết thúc', 'rời bỏ thế giới', 'từ bỏ mọi thứ'
];

const CRISIS_KEYWORDS_EN = [
  'kill myself', 'suicide', 'suicidal', 'want to die', 'don\'t want to live',
  'end my life', 'end it all', 'no reason to live',
  'self-harm', 'self harm', 'cut myself', 'hurt myself',
  'take my own life', 'not worth living', 'better off dead'
];

const ALL_CRISIS_KEYWORDS = [...CRISIS_KEYWORDS_VI, ...CRISIS_KEYWORDS_EN];

export function useCrisisDetection() {
  // Shared state — same ref across all components
  const isCrisisModalOpen = useState('crisis-modal-open', () => false);

  /**
   * Check if text contains potential crisis/self-harm content
   */
  function detectCrisis(text: string): boolean {
    if (!text || text.trim().length < 5) return false;
    const lowerText = text.toLowerCase();
    return ALL_CRISIS_KEYWORDS.some(keyword => lowerText.includes(keyword));
  }

  /**
   * Show the crisis modal
   */
  function showCrisisModal() {
    isCrisisModalOpen.value = true;
  }

  /**
   * Close the crisis modal
   */
  function closeCrisisModal() {
    isCrisisModalOpen.value = false;
  }

  return {
    isCrisisModalOpen,
    detectCrisis,
    showCrisisModal,
    closeCrisisModal,
  };
}