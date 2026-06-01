<template>
  <div class="sleep-chart">
    <!-- Period filter pills -->
    <div class="flex justify-center gap-2 mb-3">
      <button
        v-for="opt in periodOptions"
        :key="opt.value"
        @click="selectedPeriod = opt.value"
        :class="[
          'text-xs font-medium px-3 py-1 rounded-full border transition-colors',
          selectedPeriod === opt.value
            ? 'bg-primary text-white border-primary'
            : 'bg-transparent text-muted border-[var(--ui-border)] hover:border-primary/60',
        ]"
      >
        {{ opt.label }}
      </button>
    </div>

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

type Period = '7d' | '30d' | '90d' | 'all'

const selectedPeriod = ref<Period>('30d')

const periodOptions = computed(() => [
  { value: '7d' as Period,  label: t('progress.filter.week') },
  { value: '30d' as Period, label: t('progress.filter.month') },
  { value: '90d' as Period, label: t('progress.filter.threeMonths') },
  { value: 'all' as Period, label: t('progress.filter.all') },
])

const periodDays: Record<Period, number | null> = {
  '7d': 7,
  '30d': 30,
  '90d': 90,
  'all': null,
}

function formatDate(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

/**
 * One sleep score per day — latest entry wins if multiple entries exist on the same day.
 * Filtered by the selected period.
 */
const sleepData = computed(() => {
  const byDate: Record<string, number> = {}
  const days = periodDays[selectedPeriod.value]
  const cutoff = days !== null ? new Date(Date.now() - days * 86400000) : null

  props.journals
    .filter(j => {
      if (j.is_deleted || j.sleep_score === null || j.sleep_score === undefined) return false
      if (cutoff && new Date(j.created_at) < cutoff) return false
      return true
    })
    .forEach(j => {
      byDate[formatDate(new Date(j.created_at))] = j.sleep_score!
    })

  return Object.entries(byDate)
    .sort(([a], [b]) => a.localeCompare(b))
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
        { weekday: 'short', month: 'short', day: 'numeric' }
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
    minInterval: 86400000, // snap ticks to day boundaries
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
