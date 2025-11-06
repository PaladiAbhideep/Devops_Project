import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { fetchRuns, fetchRun, createRun, cancelRun, rerunPipeline, fetchPipelines } from './api';
import { Run, Step } from './types';
import { RunsList } from './components/RunsList';
import { PipelineVisualizer } from './components/PipelineVisualizer';
import { LogsPanel } from './components/LogsPanel';
import { useWebSocket } from './hooks/useWebSocket';
import { Play, RotateCw, X, Activity } from 'lucide-react';

function App() {
  const queryClient = useQueryClient();
  const [selectedRunId, setSelectedRunId] = useState<number | null>(null);
  const [selectedRun, setSelectedRun] = useState<Run | null>(null);

  // Fetch pipelines
  const { data: pipelines = [] } = useQuery({
    queryKey: ['pipelines'],
    queryFn: fetchPipelines,
  });

  // Fetch runs list
  const { data: runs = [], isLoading: runsLoading } = useQuery({
    queryKey: ['runs'],
    queryFn: () => fetchRuns({ limit: 50 }),
    refetchInterval: 5000, // Refetch every 5 seconds
  });

  // Fetch selected run details
  const { data: runDetails } = useQuery({
    queryKey: ['run', selectedRunId],
    queryFn: () => fetchRun(selectedRunId!),
    enabled: !!selectedRunId,
  });

  // WebSocket for real-time updates
  const { logs, subscribe, isConnected } = useWebSocket(
    (updatedRun) => {
      // Update run in cache
      if (selectedRun && updatedRun.runId === selectedRun.id) {
        setSelectedRun({
          ...selectedRun,
          status: updatedRun.status || selectedRun.status,
          started_at: updatedRun.startedAt || selectedRun.started_at,
          finished_at: updatedRun.finishedAt || selectedRun.finished_at,
        });
      }
      // Invalidate runs list
      queryClient.invalidateQueries({ queryKey: ['runs'] });
    },
    (updatedStep) => {
      // Update step in selected run
      if (selectedRun && selectedRun.steps) {
        const updatedSteps = selectedRun.steps.map((step) =>
          step.id === updatedStep.stepId
            ? {
                ...step,
                status: updatedStep.status || step.status,
                started_at: updatedStep.startedAt || step.started_at,
                finished_at: updatedStep.finishedAt || step.finished_at,
              }
            : step
        );
        setSelectedRun({
          ...selectedRun,
          steps: updatedSteps,
        });
      }
    }
  );

  // Create run mutation
  const createRunMutation = useMutation({
    mutationFn: createRun,
    onSuccess: (newRun) => {
      queryClient.invalidateQueries({ queryKey: ['runs'] });
      setSelectedRunId(newRun.id);
    },
  });

  // Cancel run mutation
  const cancelRunMutation = useMutation({
    mutationFn: cancelRun,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['runs'] });
      queryClient.invalidateQueries({ queryKey: ['run', selectedRunId] });
    },
  });

  // Rerun mutation
  const rerunMutation = useMutation({
    mutationFn: rerunPipeline,
    onSuccess: (newRun) => {
      queryClient.invalidateQueries({ queryKey: ['runs'] });
      setSelectedRunId(newRun.id);
    },
  });

  // Update selected run when details are fetched
  useEffect(() => {
    if (runDetails) {
      setSelectedRun(runDetails);
    }
  }, [runDetails]);

  // Subscribe to WebSocket events for selected run
  useEffect(() => {
    if (selectedRunId) {
      subscribe(selectedRunId);
    }
  }, [selectedRunId, subscribe]);

  const handleStartPipeline = (pipelineId: number) => {
    createRunMutation.mutate({
      pipelineId,
      repo: 'example/repo',
      branch: 'main',
      triggeredBy: 'manual',
    });
  };

  const handleCancelRun = () => {
    if (selectedRunId) {
      cancelRunMutation.mutate(selectedRunId);
    }
  };

  const handleRerun = () => {
    if (selectedRunId) {
      rerunMutation.mutate(selectedRunId);
    }
  };

  return (
    <div className="min-h-screen bg-slate-950 text-gray-100">
      {/* Header */}
      <header className="bg-slate-900 border-b border-slate-700 sticky top-0 z-10">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Activity className="text-blue-400" size={32} />
              <div>
                <h1 className="text-2xl font-bold text-white">CI/CD Pipeline Dashboard</h1>
                <p className="text-sm text-gray-400">Monitor and manage your pipeline runs</p>
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div
                className={`flex items-center gap-2 px-3 py-1 rounded-full text-xs ${
                  isConnected ? 'bg-green-900/30 text-green-400' : 'bg-red-900/30 text-red-400'
                }`}
              >
                <div className={`w-2 h-2 rounded-full ${isConnected ? 'bg-green-400' : 'bg-red-400'}`} />
                {isConnected ? 'Connected' : 'Disconnected'}
              </div>
              <div className="flex gap-2">
                {pipelines.slice(0, 3).map((pipeline) => (
                  <button
                    key={pipeline.id}
                    onClick={() => handleStartPipeline(pipeline.id)}
                    className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg flex items-center gap-2 transition-colors"
                  >
                    <Play size={16} />
                    {pipeline.name}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="container mx-auto px-6 py-6">
        <div className="grid grid-cols-12 gap-6">
          {/* Left Sidebar - Runs List */}
          <div className="col-span-12 lg:col-span-4 xl:col-span-3">
            <div className="bg-slate-900 rounded-lg border border-slate-700 p-4">
              <h2 className="text-lg font-semibold mb-4 text-white">Recent Runs</h2>
              {runsLoading ? (
                <div className="text-center py-8 text-gray-500">Loading...</div>
              ) : (
                <RunsList runs={runs} selectedRunId={selectedRunId} onSelectRun={setSelectedRunId} />
              )}
            </div>
          </div>

          {/* Right Content - Run Details */}
          <div className="col-span-12 lg:col-span-8 xl:col-span-9">
            {selectedRun ? (
              <div className="space-y-6">
                {/* Run Actions */}
                <div className="bg-slate-900 rounded-lg border border-slate-700 p-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <h2 className="text-xl font-bold text-white mb-1">
                        Run #{selectedRun.id}
                      </h2>
                      <p className="text-sm text-gray-400">
                        {selectedRun.pipeline_name || `Pipeline ${selectedRun.pipeline_id}`}
                      </p>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={handleRerun}
                        disabled={rerunMutation.isPending}
                        className="px-4 py-2 bg-slate-700 hover:bg-slate-600 text-white rounded-lg flex items-center gap-2 transition-colors disabled:opacity-50"
                      >
                        <RotateCw size={16} />
                        Rerun
                      </button>
                      {selectedRun.status === 'running' && (
                        <button
                          onClick={handleCancelRun}
                          disabled={cancelRunMutation.isPending}
                          className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg flex items-center gap-2 transition-colors disabled:opacity-50"
                        >
                          <X size={16} />
                          Cancel
                        </button>
                      )}
                    </div>
                  </div>
                </div>

                {/* Pipeline Visualizer */}
                <div className="bg-slate-900 rounded-lg border border-slate-700 p-6">
                  <PipelineVisualizer run={selectedRun} />
                </div>

                {/* Logs Panel */}
                <LogsPanel logs={logs} />
              </div>
            ) : (
              <div className="bg-slate-900 rounded-lg border border-slate-700 p-12 text-center">
                <Activity className="mx-auto mb-4 text-gray-600" size={64} />
                <h3 className="text-xl font-semibold text-gray-400 mb-2">
                  No Run Selected
                </h3>
                <p className="text-gray-500">
                  Select a run from the list to view details and logs
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
