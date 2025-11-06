import { Run, Step } from '../types';
import { getStatusColor, formatDuration } from '../utils/format';
import { CheckCircle2, Circle, XCircle, Loader2, Ban } from 'lucide-react';

interface PipelineVisualizerProps {
  run: Run;
}

const getStatusIcon = (status: string) => {
  switch (status) {
    case 'success':
      return <CheckCircle2 size={16} className="text-green-400" />;
    case 'failed':
      return <XCircle size={16} className="text-red-400" />;
    case 'running':
      return <Loader2 size={16} className="text-blue-400 animate-spin" />;
    case 'cancelled':
      return <Ban size={16} className="text-yellow-400" />;
    case 'pending':
    case 'queued':
    default:
      return <Circle size={16} className="text-gray-400" />;
  }
};

export const PipelineVisualizer = ({ run }: PipelineVisualizerProps) => {
  if (!run.pipeline_config || !run.steps) {
    return null;
  }

  const stageMap = new Map<string, Step[]>();
  run.steps.forEach((step) => {
    if (!stageMap.has(step.stage)) {
      stageMap.set(step.stage, []);
    }
    stageMap.get(step.stage)?.push(step);
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-white">Pipeline Stages</h3>
        <div className={`px-4 py-2 rounded-lg border font-medium ${getStatusColor(run.status)}`}>
          {run.status.toUpperCase()}
        </div>
      </div>

      <div className="space-y-6">
        {run.pipeline_config.stages.map((stage, stageIndex) => {
          const stageSteps = stageMap.get(stage.name) || [];
          const stageStatus = stageSteps.every((s) => s.status === 'success')
            ? 'success'
            : stageSteps.some((s) => s.status === 'failed')
            ? 'failed'
            : stageSteps.some((s) => s.status === 'running')
            ? 'running'
            : stageSteps.some((s) => s.status === 'cancelled')
            ? 'cancelled'
            : 'pending';

          return (
            <div key={stageIndex} className="bg-slate-900 rounded-lg border border-slate-700 p-4">
              <div className="flex items-center gap-2 mb-4">
                {getStatusIcon(stageStatus)}
                <h4 className="font-semibold text-white">{stage.name}</h4>
                <span className="text-xs text-gray-500 ml-auto">
                  {stageSteps.length} steps
                </span>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {stageSteps.map((step) => (
                  <div
                    key={step.id}
                    className={`p-3 rounded-lg border ${getStatusColor(step.status)}`}
                  >
                    <div className="flex items-start gap-2 mb-2">
                      {getStatusIcon(step.status)}
                      <div className="flex-1 min-w-0">
                        <div className="font-medium text-sm truncate">{step.name}</div>
                        <div className="text-xs text-gray-500">
                          {formatDuration(step.started_at, step.finished_at)}
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
