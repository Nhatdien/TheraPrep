// tailwind.config.js
import typography from '@tailwindcss/typography';

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './index.html',
    './src/**/*.{js,ts,jsx,tsx,vue}', // adjust to your file types
  ],
  theme: {
    extend: {
      colors: {
        illus: {
          amber: '#F59E0B',
          cream: '#FEF3C7',
          dark: '#18181b',
        },
      },
    },
  },
  plugins: [
    typography,
  ],
};
