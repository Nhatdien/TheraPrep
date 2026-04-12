<template>
  <div class="emotion-chart">
    <v-chart
      v-if="hasData"
      class="chart"
      :option="chartOption"
      autoresize
    />
    <div v-else class="flex flex-col items-center justify-center py-8 text-center">
      <UIcon name="i-lucide-pie-chart" class="w-10 h-10 text-muted mb-3" />
      <p class="text-sm text-muted">
        {{ $t('progress.emptyMoodData') }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { use } from 'echarts/core'
import { PieChart } from 'echarts/charts'
import {
  TooltipComponent,
  LegendComponent,
} from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'
import type { LocalJournal } from '~/types/user_journal'

use([PieChart, TooltipComponent, LegendComponent, CanvasRenderer])

const { t } = useI18n()

const props = defineProps<{
  journals: LocalJournal[]
}>()

/**
 * Color palette mapping mood score (1-10) to colors.
 * Goes from red (negative) through yellow (neutral) to green (positive).
 */
const scoreColors: Record<number, string> = {
  1: '#e74c3c',
  2: '#e85d4a',
  3: '#e96f58',
  4: '#e67e22',
  5: '#f39c12',
  6: '#d4ac0d',
  7: '#52be80',
  8: '#27ae60',
  9: '#2ecc71',
  10: '#1abc9c',
}

/**
 * Compute emotion frequency from journal mood_score values.
 * Uses mood_score (1-10) for reliable language-independent matching.
 */
const emotionDistribution = computed(() => {
  const counts: Record<number, number> = {}

  props.journals
    .filter(j => !j.is_deleted && j.mood_score)
    .forEach(j => {
      const score = j.mood_score!
      counts[score] = (counts[score] || 0) + 1
    })

  return Object.entries(counts)
    .map(([score, value]) => {
      const s = Number(score)
      return {
        name: t(`progress.mood.${s}`),
        value,
        score: s,
        itemStyle: { color: scoreColors[s] || '#94a3b8' },
      }
    })
    .sort((a, b) => a.score - b.score)
})

const hasData = computed(() => emotionDistribution.value.length > 0)

const chartOption = computed(() => ({
  tooltip: {
    trigger: 'item',
    formatter: (params: any) => {
      const percent = params.percent?.toFixed(1)
      return `${params.name}: ${params.value} (${percent}%)`
    },
  },
  legend: {
    orient: 'horizontal',
    bottom: 0,
    textStyle: {
      color: '#94a3b8',
      fontSize: 11,
    },
    itemWidth: 10,
    itemHeight: 10,
    itemGap: 8,
  },
  series: [
    {
      type: 'pie',
      radius: ['40%', '70%'],
      center: ['50%', '45%'],
      avoidLabelOverlap: true,
      padAngle: 2,
      itemStyle: {
        borderRadius: 4,
      },
      label: {
        show: false,
      },
      emphasis: {
        label: {
          show: true,
          fontSize: 14,
          fontWeight: 'bold',
          formatter: '{b}\n{c}',
        },
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.3)',
        },
      },
      data: emotionDistribution.value,
    },
  ],
}))
</script>

<style scoped>
.chart {
  min-height: 280px;
  width: 100%;
}
</style>
