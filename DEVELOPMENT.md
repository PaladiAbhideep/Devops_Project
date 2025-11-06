# Development Guide

## 🏗️ Architecture Deep Dive

### System Components

#### 1. Frontend (React + Vite)
**Purpose**: User interface for monitoring pipelines

**Key Features**:
- Real-time updates via WebSocket
- Responsive dashboard with Tailwind CSS
- Optimistic UI updates with React Query
- Component-based architecture

**Main Components**:
- `App.tsx` - Main application container
- `RunsList.tsx` - Displays pipeline runs
- `PipelineVisualizer.tsx` - Shows stages and steps
- `LogsPanel.tsx` - Real-time log streaming
- `useWebSocket.ts` - WebSocket connection hook

#### 2. Backend (Express + Socket.IO)
**Purpose**: REST API and WebSocket server

**Responsibilities**:
- Handle HTTP requests for CRUD operations
- Manage WebSocket connections
- Subscribe to Redis pub/sub
- Forward events to connected clients
- Database operations

**Key Files**:
- `index.ts` - Server setup and WebSocket handling
- `routes/pipelines.ts` - Pipeline endpoints
- `routes/runs.ts` - Run management endpoints
- `db.ts` - PostgreSQL client
- `redis.ts` - Redis clients (pub and sub)

#### 3. Worker (Pipeline Simulator)
**Purpose**: Simulate pipeline execution

**Responsibilities**:
- Poll Redis queue for jobs
- Simulate step execution with delays
- Generate realistic logs
- Publish events to Redis pub/sub
- Update database with run progress

**Key Files**:
- `index.ts` - Queue processing loop
- `simulator.ts` - Pipeline simulation logic
- `db.ts` - Database client
- `redis.ts` - Redis client

### Data Flow

```
1. User clicks "Start Pipeline" in UI
   ↓
2. Frontend → POST /api/runs → Backend
   ↓
3. Backend creates run in PostgreSQL
   ↓
4. Backend pushes job to Redis queue (LPUSH run-queue)
   ↓
5. Worker pops job from queue (BRPOP run-queue)
   ↓
6. Worker simulates pipeline:
   - Updates steps in database
   - Publishes events to Redis channel (PUBLISH run:{id})
   ↓
7. Backend subscribes to Redis channel (PSUBSCRIBE run:*)
   ↓
8. Backend forwards events via Socket.IO
   ↓
9. Frontend receives events and updates UI
```

## 🔧 Development Setup

### Prerequisites
- Node.js 20+
- Docker Desktop
- VS Code (recommended)
- PostgreSQL client (optional, for debugging)

### Initial Setup

1. **Install dependencies**
```powershell
# Backend
cd backend
npm install

# Worker
cd ../worker
npm install

# Frontend
cd ../frontend
npm install
```

2. **Setup environment files**
```powershell
# Backend
cd backend
copy .env.example .env

# Worker
cd ../worker
copy .env.example .env

# Frontend
cd ../frontend
copy .env.example .env
```

3. **Start infrastructure**
```powershell
# Start only DB and Redis
docker-compose up -d db redis
```

4. **Run services locally**
```powershell
# Terminal 1 - Backend
cd backend
npm run dev

# Terminal 2 - Worker
cd worker
npm run dev

# Terminal 3 - Frontend
cd frontend
npm run dev
```

### Development Workflow

#### Hot Reload
All services support hot reload:
- **Backend/Worker**: Using `tsx watch`
- **Frontend**: Using Vite HMR

#### Database Changes
1. Modify `infra/init.sql`
2. Restart database:
```powershell
docker-compose restart db
# Or for fresh start:
docker-compose down -v
docker-compose up -d db
```

#### Adding New API Endpoints

1. **Create route handler** in `backend/src/routes/`
2. **Register route** in `backend/src/index.ts`
3. **Add API function** in `frontend/src/api.ts`
4. **Use in component** with React Query

Example:
```typescript
// backend/src/routes/artifacts.ts
router.get('/:runId/artifacts', async (req, res) => {
  const artifacts = await db.query('SELECT * FROM artifacts WHERE run_id = $1', [req.params.runId]);
  res.json(artifacts.rows);
});

// frontend/src/api.ts
export const fetchArtifacts = async (runId: number) => {
  const { data } = await api.get(`/api/artifacts/${runId}`);
  return data;
};

// In component
const { data: artifacts } = useQuery({
  queryKey: ['artifacts', runId],
  queryFn: () => fetchArtifacts(runId),
});
```

## 🧪 Testing

### Manual Testing

#### Test Pipeline Execution
```powershell
# Start a run
curl -X POST http://localhost:4000/api/runs `
  -H "Content-Type: application/json" `
  -d '{\"pipelineId\": 1, \"repo\": \"test/repo\", \"branch\": \"main\", \"triggeredBy\": \"test\"}'

# Get run details
curl http://localhost:4000/api/runs/1

# Cancel run
curl -X POST http://localhost:4000/api/runs/1/cancel
```

#### Test WebSocket
```javascript
// In browser console
const socket = io('http://localhost:4000', { path: '/ws' });
socket.on('connect', () => console.log('Connected'));
socket.emit('subscribe', { runId: 1 });
socket.on('run:log', (data) => console.log('Log:', data));
```

### Database Queries

```sql
-- View all runs
SELECT * FROM runs ORDER BY created_at DESC LIMIT 10;

-- View run with steps
SELECT r.*, json_agg(s.*) as steps
FROM runs r
LEFT JOIN steps s ON s.run_id = r.id
WHERE r.id = 1
GROUP BY r.id;

-- View recent logs
SELECT * FROM logs ORDER BY ts DESC LIMIT 100;

-- Clean up old runs
DELETE FROM runs WHERE created_at < NOW() - INTERVAL '7 days';
```

### Redis Commands

```powershell
# Connect to Redis
docker-compose exec redis redis-cli

# Check queue length
LLEN run-queue

# View queue contents
LRANGE run-queue 0 -1

# Monitor pub/sub messages
PSUBSCRIBE run:*

# View all keys
KEYS *
```

## 📦 Building for Production

### Docker Build

```powershell
# Build all services
docker-compose build

# Build specific service
docker-compose build backend
```

### TypeScript Compilation

```powershell
# Backend
cd backend
npm run build
# Output: dist/

# Worker
cd worker
npm run build
# Output: dist/

# Frontend
cd frontend
npm run build
# Output: dist/
```

## 🎨 Frontend Development

### Adding New Component

```typescript
// src/components/NewComponent.tsx
import { FC } from 'react';

interface NewComponentProps {
  title: string;
}

export const NewComponent: FC<NewComponentProps> = ({ title }) => {
  return (
    <div className="bg-slate-900 rounded-lg p-4">
      <h3 className="text-white font-semibold">{title}</h3>
    </div>
  );
};
```

### Tailwind Customization

Edit `frontend/tailwind.config.js`:

```javascript
theme: {
  extend: {
    colors: {
      brand: {
        500: '#3b82f6',
        600: '#2563eb',
      }
    }
  }
}
```

### State Management Pattern

```typescript
// Use React Query for server state
const { data, isLoading } = useQuery({
  queryKey: ['runs'],
  queryFn: fetchRuns,
});

// Use useState for local UI state
const [selectedId, setSelectedId] = useState<number | null>(null);

// Use mutations for updates
const mutation = useMutation({
  mutationFn: createRun,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['runs'] });
  },
});
```

## 🔐 Security Considerations

### For Production

1. **Add Authentication**
   - Implement JWT tokens
   - Protect API endpoints
   - Secure WebSocket connections

2. **Environment Variables**
   - Never commit `.env` files
   - Use secrets management (Docker secrets, Kubernetes secrets)
   - Rotate credentials regularly

3. **Input Validation**
   - Validate all user inputs
   - Sanitize data before database queries
   - Use parameterized queries (already implemented)

4. **CORS Configuration**
   - Restrict origins in production
   - Configure Socket.IO CORS properly

5. **Rate Limiting**
   - Add rate limiting to API endpoints
   - Prevent queue flooding

## 🐛 Debugging

### Backend Debugging
```typescript
// Add debug logs
import { logger } from './logger';
logger.debug('Debug message', { data: someData });
```

### Worker Debugging
```typescript
// Adjust simulation timing
export const config = {
  worker: {
    minStepDuration: 1000, // Faster for testing
    maxStepDuration: 2000,
  }
};
```

### Frontend Debugging
```typescript
// React Query DevTools (already installed)
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

// In App.tsx
<ReactQueryDevtools initialIsOpen={false} />
```

### Useful Commands

```powershell
# View backend logs with timestamps
docker-compose logs -f --timestamps backend

# Watch database activity
docker-compose exec db psql -U postgres -d cicd_dashboard -c "SELECT * FROM pg_stat_activity;"

# Monitor Redis pub/sub
docker-compose exec redis redis-cli PSUBSCRIBE "run:*"

# Check Docker resource usage
docker stats
```

## 📊 Performance Optimization

### Database
- Add indexes on frequently queried columns
- Use connection pooling (already implemented)
- Archive old runs periodically

### Redis
- Set TTL on temporary data
- Use Redis pipelining for bulk operations
- Monitor memory usage

### Frontend
- Implement virtual scrolling for large log lists
- Lazy load components
- Optimize re-renders with React.memo

### Worker
- Process multiple jobs concurrently (carefully)
- Batch database updates
- Implement backpressure

## 🔄 CI/CD for the Dashboard Itself

### GitHub Actions Example

```yaml
name: CI

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: npm ci
      - run: npm test
      - run: npm run build
```

## 📝 Code Style

- Use **TypeScript** for type safety
- Follow **ESLint** rules
- Use **Prettier** for formatting
- Write meaningful commit messages
- Document complex logic

## 🤝 Contributing Guidelines

1. Create feature branch from `main`
2. Make changes with tests
3. Ensure all linters pass
4. Update documentation
5. Submit PR with description

---

**Happy Coding! 🚀**
