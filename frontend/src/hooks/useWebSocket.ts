import { useEffect, useRef, useState } from 'react';
import { io, Socket } from 'socket.io-client';
import { config } from '../config';
import { Log, Run, Step } from '../types';

interface UseWebSocketReturn {
  logs: Log[];
  subscribe: (runId: number) => void;
  unsubscribe: () => void;
  isConnected: boolean;
}

export const useWebSocket = (
  onRunUpdate?: (run: Partial<Run>) => void,
  onStepUpdate?: (step: Partial<Step>) => void
): UseWebSocketReturn => {
  const [logs, setLogs] = useState<Log[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const socketRef = useRef<Socket | null>(null);
  const currentRunId = useRef<number | null>(null);

  useEffect(() => {
    // Initialize socket connection
    const socket = io(config.wsUrl, {
      path: config.wsPath,
      transports: ['websocket', 'polling'],
    });

    socket.on('connect', () => {
      console.log('WebSocket connected');
      setIsConnected(true);
    });

    socket.on('disconnect', () => {
      console.log('WebSocket disconnected');
      setIsConnected(false);
    });

    socket.on('run:status', (data: any) => {
      console.log('Run status update:', data);
      if (onRunUpdate) {
        onRunUpdate(data);
      }
    });

    socket.on('run:step:update', (data: any) => {
      console.log('Step update:', data);
      if (onStepUpdate) {
        onStepUpdate(data);
      }
    });

    socket.on('run:log', (data: Log) => {
      console.log('Log received:', data);
      setLogs((prev) => [...prev, data]);
    });

    socketRef.current = socket;

    return () => {
      socket.disconnect();
    };
  }, [onRunUpdate, onStepUpdate]);

  const subscribe = (runId: number) => {
    if (socketRef.current && runId !== currentRunId.current) {
      // Unsubscribe from previous run if any
      if (currentRunId.current !== null) {
        socketRef.current.emit('unsubscribe', { runId: currentRunId.current });
      }

      // Clear logs and subscribe to new run
      setLogs([]);
      socketRef.current.emit('subscribe', { runId });
      currentRunId.current = runId;
      console.log('Subscribed to run:', runId);
    }
  };

  const unsubscribe = () => {
    if (socketRef.current && currentRunId.current !== null) {
      socketRef.current.emit('unsubscribe', { runId: currentRunId.current });
      currentRunId.current = null;
      setLogs([]);
      console.log('Unsubscribed from run');
    }
  };

  return {
    logs,
    subscribe,
    unsubscribe,
    isConnected,
  };
};
