import type { CIRun, DeployedVersion, PublishedVersion } from '../types/ci'
import type { EdgeHealth } from './ciEdgeStyle'

export interface CINodeData {
  label: string
  repoName: string
  runs: CIRun[]
  nodeHeight: number
  publishedVersion?: PublishedVersion
  deployedVersion?: DeployedVersion
  versionError?: string
  // Aggregated health of this node's incident verification edges. When not
  // 'idle', overrides pipeline-run status for border/bg/glow so the node
  // reads the same color as its edges (broken > active > healthy).
  health?: EdgeHealth
}

// Estimate node height based on content.
const HEIGHT_EMPTY = 66
const HEIGHT_WITH_RUN = 106
const HEIGHT_WITH_MORE = 123
const HEIGHT_VERSION_LINE = 16

export function estimateNodeHeight(runs: CIRun[], hasVersion: boolean, hasError: boolean): number {
  let h = HEIGHT_EMPTY
  if (runs.length > 1) h = HEIGHT_WITH_MORE
  else if (runs.length === 1) h = HEIGHT_WITH_RUN
  if (hasVersion || hasError) h += HEIGHT_VERSION_LINE
  return h
}
