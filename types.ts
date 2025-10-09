
export interface Task {
  id: string;
  action: string;
  requirement: string;
  refs: string;
  completed: boolean;
}

export interface Section {
  id: string;
  title: string;
  icon: string;
  description: string;
  tasks: Task[];
}

export interface ArchitectureMetric {
  label: string;
  detail: string;
}

export interface Metrics {
  revenueStreams: string;
  y1Projection: string;
  y3Projection: string;
  complianceStatus: string;
  architecture: ArchitectureMetric[];
}
