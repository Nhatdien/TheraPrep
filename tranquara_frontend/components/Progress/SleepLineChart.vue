<template>
  <div class="sleep-chart">
    <v-chart
      v-if="hasData"
      class="chart"
      :option="chartOption"
      autoresize
    />
    <div v-else class="flex flex-col items-center justify-center py-8 text-center">
      <UIcon name="i-lucide-moon" class="w-10 h-10 text-muted mb-3" />
      <p class="text-sm text-muted">
        {{ $t('progress.noSleepData') }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { use } from 'echarts/core'
import { LineChart } from 'echarts/charts'
import {
  GridComponent,
  TooltipComponent,
} from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'
import type { LocalJournal } from '~/types/user_journal'

use([LineChart, GridComponent, TooltipComponent, CanvasRenderer])

const { t, locale } = useI18n()

const props = defineProps<{
  journals: LocalJournal[]
}>()

/**
 * Extract sleep quality score (0–100) from journal HTML content.
 * Matches entries where the question text mentions sleep and the answer is numeric.
 */
function extractSleepScore(content: string): number | null {
  if (!content) return null
  try {
    const parser = new DOMParser()
    const doc = parser.parseFromString(content, 'text/html')
    for (const block of Array.from(doc.querySelectorAll('.journal-entry'))) {
      const questionEl = block.querySelector('.journal-question')
      const answerEl = block.querySelector('.journal-answer')
      if (!questionEl || !answerEl) continue
      const key = (questionEl.textContent || '').toLowerCase()
      const isSleepKey = key.includes('sleep') || key.includes('ngủ') || key.includes('giấc')
      if (!isSleepKey) continue
      const raw = (answerEl.textContent || '').trim()
      const numVal = Number(raw)
      if (!isNaN(numVal) && numVal >= 0 && numVal <= 100) return numVal
    }
  } catch {
    // ignore DOM parse errors in non-browser environments
  }
  return null
}

function formatDate(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

/**
 * One sleep score per day — latest entry wins if multiple entries exist on the same day.
 * Sorted chronologically and capped at the last 60 data points.
 */
const sleepData = computed(() => {
  const byDate: Record<string, number> = {}

  props.journals
    .filter(j => !j.is_deleted)
    .forEach(j => {
      const score = extractSleepScore(j.content_html || j.content)
      if (score !== null) {
        byDate[formatDate(new Date(j.created_at))] = score
      }
    })

  return Object.entries(byDate)
    .sort(([a], [b]) => a.localeCompare(b))
    .slice(-60)
    .map(([date, score]) => [date, score] as [string, number])
})

const hasData = computed(() => sleepData.value.length > 0)

const chartOption = computed(() => ({
  tooltip: {
    trigger: 'axis',
    formatter: (params: any) => {
      const p = params[0]
      const dateObj = new Date(p.data[0])
      const formattedDate = dateObj.toLocaleDateString(
        locale.value === 'vi' ? 'vi-VN' : 'en-US',
        { month: 'short', day: 'numeric' }
      )
      return `${formattedDate}: <b>${p.data[1]}%</b>`
    },
    backgroundColor: 'rgba(15, 23, 42, 0.88)',
    borderColor: 'transparent',
    textStyle: { color: '#e2e8f0', fontSize: 12 },
    extraCssText: 'border-radius: 8px; padding: 8px 12px;',
  },
  grid: {
    top: 12,
    right: 12,
    bottom: 28,
    left: 44,
    containLabel: false,
  },
  xAxis: {
    type: 'time',
    boundaryGap: false,
    axisLine: { show: false },
    axisTick: { show: false },
    axisLabel: {
      color: '#64748b',
      fontSize: 10,
      formatter: (value: number) => {
        const d = new Date(value)
        if (locale.value === 'vi') {
          return `${d.getDate()}/${d.getMonth() + 1}`
        }
        return d.toLocaleString('en-US', { month: 'short', day: 'numeric' })
      },
    },
    splitLine: { show: false },
  },
  yAxis: {
    type: 'value',
    min: 0,
    max: 100,
    splitNumber: 4,
    axisLabel: {
      color: '#64748b',
      fontSize: 10,
      formatter: (v: number) => `${v}%`,
    },
    splitLine: {
      lineStyle: { color: '#1e293b', type: 'dashed' },
    },
    axisLine: { show: false },
    axisTick: { show: false },
  },
  series: [
    {
      type: 'line',
      smooth: 0.4,
      symbol: 'circle',
      symbolSize: sleepData.value.length > 20 ? 4 : 7,
      showSymbol: sleepData.value.length <= 30,
      data: sleepData.value,
      lineStyle: {
        color: '#818cf8',
        width: 2.5,
      },
      itemStyle: {
        color: '#818cf8',
        borderColor: '#0f172a',
        borderWidth: 2,
      },
      areaStyle: {
        color: {
          type: 'linear',
          x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: 'rgba(129, 140, 248, 0.28)' },
            { offset: 1, color: 'rgba(129, 140, 248, 0.02)' },
          ],
        },
      },
    },
  ],
}))
</script>

<style scoped>
.chart {
  min-height: 200px;
  width: 100%;
}
</style>
