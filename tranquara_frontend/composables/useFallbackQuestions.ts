/**
 * Fallback Questions Composable
 * 
 * Provides pre-written therapeutic questions when AI is unavailable.
 * Questions are organized by language (vi/en) and direction.
 * Uses i18n for the fallback prefix message.
 */

const FALLBACK_QUESTIONS: Record<string, Record<string, string[]>> = {
  vi: {
    why: [
      'Điều gì thực sự nằm sau suy nghĩ này của bạn?',
      'Bạn có nhận ra điều gì kích hoạt cảm xúc này không?',
      'Lần đầu tiên bạn cảm thấy thế này là khi nào?',
      'Có điều gì trong quá khứ khiến bạn phản ứng như vậy không?',
    ],
    emotions: [
      'Bạn có thể mô tả cảm xúc này chi tiết hơn không?',
      'Cảm giác này nằm ở đâu trong cơ thể bạn?',
      'Cảm xúc này có làm bạn nhớ đến một thời điểm nào khác không?',
      'Nếu cảm xúc này có thể nói, nó sẽ nói gì?',
    ],
    patterns: [
      'Bạn có thường xuyên cảm thấy như vậy không?',
      'Điều gì thường xảy ra trước khi bạn có cảm giác này?',
      'Bạn thường phản ứng thế nào khi gặp tình huống tương tự?',
      'Có mẫu chung nào giữa các lần bạn cảm thấy như vậy không?',
    ],
    challenge: [
      'Có góc nhìn nào khác về tình huống này không?',
      'Nếu một người bạn kể cho bạn chuyện này, bạn sẽ nói gì?',
      'Điều gì sẽ xảy ra nếu bạn nhìn nhận khác đi?',
      'Có bằng chứng nào chống lại suy nghĩ hiện tại của bạn không?',
    ],
    growth: [
      'Một bước nhỏ nào bạn có thể làm hôm nay để cảm thấy tốt hơn?',
      'Bạn đã vượt qua tình huống khó khăn nào tương tự trước đây?',
      'Điều gì bạn muốn cảm thấy vào ngày mai?',
      'Bạn có thể học được gì từ trải nghiệm này?',
    ],
    generic: [
      'Điều gì đang nặng lòng nhất với bạn ngay lúc này?',
      'Bạn cảm thấy cơ thể mình thế nào khi nghĩ về điều đó?',
      'Nếu được viết thư cho chính mình lúc này, bạn sẽ viết gì?',
      'Bạn cần gì nhất cho bản thân mình ngay bây giờ?',
    ],
  },
  en: {
    why: [
      'What\'s really behind this thought you\'re having?',
      'Can you identify what triggered this feeling?',
      'When was the first time you felt this way?',
      'Is there something from your past that makes you react this way?',
    ],
    emotions: [
      'Can you describe this emotion in more detail?',
      'Where in your body do you feel this sensation?',
      'Does this emotion remind you of another time in your life?',
      'If this emotion could speak, what would it say?',
    ],
    patterns: [
      'Do you find yourself feeling this way often?',
      'What usually happens before you get this feeling?',
      'How do you typically react in similar situations?',
      'Is there a common thread between the times you feel this way?',
    ],
    challenge: [
      'Is there another way to look at this situation?',
      'If a friend told you this story, what would you say to them?',
      'What would happen if you saw this differently?',
      'Is there any evidence that contradicts your current thinking?',
    ],
    growth: [
      'What\'s one small step you could take today to feel better?',
      'Have you overcome a similar difficult situation before?',
      'How would you like to feel tomorrow?',
      'What might you learn from this experience?',
    ],
    generic: [
      'What\'s weighing on you the most right now?',
      'How does your body feel when you think about that?',
      'If you could write a letter to yourself right now, what would you say?',
      'What do you need most for yourself right now?',
    ],
  },
};

export function useFallbackQuestions() {
  const { locale } = useI18n();

  /**
   * Get a random fallback question for a given direction
   * Automatically uses the current locale (vi/en)
   */
  function getFallbackQuestion(direction: string): string {
    const lang = locale.value === 'vi' ? 'vi' : 'en';
    const langQuestions = FALLBACK_QUESTIONS[lang] || FALLBACK_QUESTIONS['en'];
    const questions = langQuestions[direction] || langQuestions['generic'];
    const randomIndex = Math.floor(Math.random() * questions.length);
    return questions[randomIndex];
  }

  return {
    getFallbackQuestion,
  };
}