const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000';
const WS_URL = import.meta.env.VITE_WS_URL || 'http://localhost:4000';

export const config = {
  apiUrl: API_URL,
  wsUrl: WS_URL,
  wsPath: '/ws',
};
