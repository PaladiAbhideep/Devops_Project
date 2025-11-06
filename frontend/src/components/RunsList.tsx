import { Run } from '../types';
import { getStatusColor, formatDateTime, formatDuration } from '../utils/format';
import { Clock, GitBranch, GitCommit, User } from 'lucide-react';

interface RunsListProps {
  runs: Run[];
  selectedRunId: number | null;
  onSelectRun: (runId: number) => void;
}

export const RunsList = ({ runs, selectedRunId, onSelectRun }: RunsListProps) => {
  return (
    <div className="space-y-2">
      {runs.map((run) => (
        <div
          key={run.id}
          onClick={() => onSelectRun(run.id)}
          className={`p-4 rounded-lg border cursor-pointer transition-colors ${
            selectedRunId === run.id
              ? 'border-blue-500 bg-slate-800'
              : 'border-slate-700 bg-slate-900 hover:bg-slate-800'
          }`}
        >
          <div className="flex items-start justify-between mb-2">
            <div className="flex-1">
              <h3 className="font-semibold text-white mb-1">
                {run.pipeline_name || `Pipeline ${run.pipeline_id}`}
              </h3>
              <div className="flex items-center gap-3 text-sm text-gray-400">
                {run.repo && (
                  <span className="flex items-center gap-1">
                    <GitCommit size={14} />
                    {run.repo}
                  </span>
                )}
                {run.branch && (
                  <span className="flex items-center gap-1">
                    <GitBranch size={14} />
                    {run.branch}
                  </span>
                )}
                {run.triggered_by && (
                  <span className="flex items-center gap-1">
                    <User size={14} />
                    {run.triggered_by}
                  </span>
                )}
              </div>
            </div>
            <span
              className={`px-3 py-1 rounded-full text-xs font-medium border ${getStatusColor(
                run.status
              )}`}
            >
              {run.status.toUpperCase()}
            </span>
          </div>
          <div className="flex items-center gap-4 text-xs text-gray-500">
            <span className="flex items-center gap-1">
              <Clock size={12} />
              {formatDateTime(run.created_at)}
            </span>
            {run.started_at && (
              <span>
                Duration: {formatDuration(run.started_at, run.finished_at)}
              </span>
            )}
          </div>
        </div>
      ))}
      {runs.length === 0 && (
        <div className="text-center py-12 text-gray-500">
          No pipeline runs found
        </div>
      )}
    </div>
  );
};
