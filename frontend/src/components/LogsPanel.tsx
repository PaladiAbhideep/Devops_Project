import { useEffect, useRef } from 'react';
import { Log } from '../types';
import { getLogLevelColor, formatTime } from '../utils/format';
import { Terminal } from 'lucide-react';

interface LogsPanelProps {
  logs: Log[];
  autoScroll?: boolean;
}

export const LogsPanel = ({ logs, autoScroll = true }: LogsPanelProps) => {
  const logsEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (autoScroll && logsEndRef.current) {
      logsEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [logs, autoScroll]);

  return (
    <div className="bg-slate-950 rounded-lg border border-slate-700 overflow-hidden">
      <div className="flex items-center gap-2 px-4 py-2 bg-slate-900 border-b border-slate-700">
        <Terminal size={16} className="text-gray-400" />
        <span className="text-sm font-medium text-gray-300">Logs</span>
        <span className="text-xs text-gray-500 ml-auto">
          {logs.length} lines
        </span>
      </div>
      <div className="p-4 font-mono text-sm max-h-[500px] overflow-y-auto">
        {logs.length === 0 ? (
          <div className="text-gray-500 text-center py-8">
            No logs available. Logs will appear here when the pipeline runs.
          </div>
        ) : (
          <div className="space-y-1">
            {logs.map((log, index) => (
              <div key={index} className="flex gap-3 hover:bg-slate-900 px-2 py-1 rounded">
                <span className="text-gray-600 select-none shrink-0">
                  {formatTime(log.ts)}
                </span>
                <span className={`shrink-0 w-16 ${getLogLevelColor(log.level)}`}>
                  [{log.level.toUpperCase()}]
                </span>
                <span className="text-gray-300 break-all">{log.message}</span>
              </div>
            ))}
            <div ref={logsEndRef} />
          </div>
        )}
      </div>
    </div>
  );
};
