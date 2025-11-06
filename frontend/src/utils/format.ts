import { RunStatus, StepStatus, LogLevel } from '../types';

export const getStatusColor = (status: RunStatus | StepStatus): string => {
  switch (status) {
    case 'pending':
    case 'queued':
      return 'text-gray-400 bg-gray-800 border-gray-700';
    case 'running':
      return 'text-blue-400 bg-blue-900/30 border-blue-700';
    case 'success':
      return 'text-green-400 bg-green-900/30 border-green-700';
    case 'failed':
      return 'text-red-400 bg-red-900/30 border-red-700';
    case 'cancelled':
      return 'text-yellow-400 bg-yellow-900/30 border-yellow-700';
    default:
      return 'text-gray-400 bg-gray-800 border-gray-700';
  }
};

export const getLogLevelColor = (level: LogLevel): string => {
  switch (level) {
    case 'error':
      return 'text-red-400';
    case 'warn':
      return 'text-yellow-400';
    case 'debug':
      return 'text-gray-500';
    case 'info':
    default:
      return 'text-gray-300';
  }
};

export const formatDuration = (start: string | null, end: string | null): string => {
  if (!start) return '-';
  if (!end) return 'Running...';
  
  const ms = new Date(end).getTime() - new Date(start).getTime();
  const seconds = Math.floor(ms / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  
  if (hours > 0) {
    return `${hours}h ${minutes % 60}m ${seconds % 60}s`;
  } else if (minutes > 0) {
    return `${minutes}m ${seconds % 60}s`;
  } else {
    return `${seconds}s`;
  }
};

export const formatDateTime = (date: string | null): string => {
  if (!date) return '-';
  return new Date(date).toLocaleString();
};

export const formatTime = (date: string): string => {
  return new Date(date).toLocaleTimeString();
};
