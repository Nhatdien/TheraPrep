import type { Component } from 'vue';
import IlluSleep from './IlluSleep.vue';
import IlluBrain from './IlluBrain.vue';
import IlluBreathing from './IlluBreathing.vue';
import IlluAnxiety from './IlluAnxiety.vue';
import IlluMindfulness from './IlluMindfulness.vue';
import IlluTherapy from './IlluTherapy.vue';
import IlluDaily from './IlluDaily.vue';
import IlluProgress from './IlluProgress.vue';
import IlluJournaling from './IlluJournaling.vue';
import IlluFallback from './IlluFallback.vue';

const KEYWORD_MAP: Array<{ keywords: string[]; component: Component }> = [
  { keywords: ['sleep', 'rest', 'insomnia', 'bedtime', 'night'], component: IlluSleep },
  { keywords: ['adhd', 'attention', 'focus', 'cognitive', 'brain'], component: IlluBrain },
  { keywords: ['breath', 'breathing', 'grounding', 'senses', 'ground'], component: IlluBreathing },
  { keywords: ['anxiety', 'stress', 'worry', 'sos', 'crisis', 'well-being', 'wellbeing'], component: IlluAnxiety },
  { keywords: ['mindful', 'meditation', 'calm', 'awareness', 'leaf', 'spiritual'], component: IlluMindfulness },
  { keywords: ['therapy', 'session', 'relationship', 'connect', 'connect', 'heart', 'partner'], component: IlluTherapy },
  { keywords: ['daily', 'check-in', 'morning', 'evening', 'routine', 'check in', 'sun'], component: IlluDaily },
  { keywords: ['progress', 'journey', 'growth', 'streak', 'achievement'], component: IlluProgress },
  { keywords: ['journal', 'write', 'reflect', 'prompt', 'template', 'feather', 'quill'], component: IlluJournaling },
];

export function getIllustrationComponent(titleOrCategory: string): Component {
  const text = (titleOrCategory || '').toLowerCase();
  for (const entry of KEYWORD_MAP) {
    if (entry.keywords.some(kw => text.includes(kw))) {
      return entry.component;
    }
  }
  return IlluFallback;
}

export {
  IlluSleep,
  IlluBrain,
  IlluBreathing,
  IlluAnxiety,
  IlluMindfulness,
  IlluTherapy,
  IlluDaily,
  IlluProgress,
  IlluJournaling,
  IlluFallback,
};
