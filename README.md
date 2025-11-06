# CI/CD Pipeline Dashboard

A full-stack real-time CI/CD pipeline monitoring dashboard that simulates pipeline runs with live streaming logs and WebSocket updates.

![CI/CD Dashboard](https://img.shields.io/badge/Status-MVP-success)
![License](https://img.shields.io/badge/License-MIT-blue)

## 🚀 Features

### MVP Features
- ✅ **Simulate Pipeline Runs** - Create, run, and cancel pipeline executions
- ✅ **Live Streaming Logs** - Real-time log streaming via WebSocket
- ✅ **Run State Tracking** - Track status, timestamps, duration, and metadata
- ✅ **Run History & Filtering** - Browse and filter by repo, branch, and status
- ✅ **Visual Pipeline Stages** - Interactive stage and step visualization
- ✅ **Real-time Updates** - Socket.IO powered live updates
- ⭐ **Jenkins Integration** - Real pipelines triggered from GitHub repositories
- ⭐ **GitHub Webhooks** - Automatic builds on code push

## 🏗️ Architecture

```
┌─────────────┐     REST API      ┌─────────────┐
│   Frontend  │ ←─────────────────→│   Backend   │
│  (React +   │                    │  (Express + │
│   Vite)     │ ←─── WebSocket ───→│  Socket.IO) │
└─────────────┘                    └──────┬──────┘
                                          │
                                          ↓
                    ┌──────────────────────────────────┐
                    │                                  │
              ┌─────▼─────┐                    ┌──────▼──────┐
              │ PostgreSQL │                    │    Redis    │
              │    (DB)    │                    │  (Pub/Sub)  │
              └────────────┘                    └──────┬──────┘
                                                       │
                                                       ↓
                                                ┌──────────────┐
                                                │    Worker    │
                                                │  (Simulator) │
                                                └──────────────┘
```

### Flow
1. **User** triggers a pipeline run via the UI
2. **Backend** creates run record in PostgreSQL and enqueues job to Redis
3. **Worker** picks up job, simulates pipeline execution, publishes logs to Redis pub/sub
4. **Backend** subscribes to Redis pub/sub and forwards events to WebSocket clients
5. **Frontend** receives real-time updates and displays logs/status

## 📋 Tech Stack

### Frontend
- **React 18** with TypeScript
- **Vite** - Fast build tool
- **Tailwind CSS** - Utility-first styling
- **TanStack Query (React Query)** - Data fetching and caching
- **Socket.IO Client** - Real-time WebSocket communication
- **Lucide React** - Beautiful icons

### Backend
- **Node.js** with TypeScript
- **Express** - Web framework
- **Socket.IO** - WebSocket server
- **PostgreSQL** - Relational database
- **node-postgres (pg)** - PostgreSQL client
- **ioredis** - Redis client
- **Winston** - Logging

### Worker
- **Node.js** with TypeScript
- **ioredis** - Redis client for pub/sub
- **PostgreSQL** - Database access

### Infrastructure
- **Docker Compose** - Local orchestration
- **PostgreSQL 15** - Database
- **Redis 7** - In-memory cache and pub/sub
- **Jenkins** - CI/CD automation server (LTS with JDK 17)

## 🛠️ Getting Started

### Prerequisites
- **Docker** and **Docker Compose** installed
- **Node.js 20+** (for local development without Docker)
- **npm** or **yarn**

### Quick Start with Docker

1. **Clone the repository**
```bash
cd "C:\Users\tests\Downloads\cicd project"
```

2. **Start all services**
```powershell
docker-compose up -d
```

3. **Access the application**
- Frontend: http://localhost:3000
- Backend API: http://localhost:4000
- **Jenkins**: http://localhost:8080 (admin/admin123)
- Health Check: http://localhost:4000/health

4. **View logs**
```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f worker
docker-compose logs -f frontend
```

5. **Stop services**
```powershell
docker-compose down
```

6. **Clean up (remove volumes)**
```powershell
docker-compose down -v
```

### Local Development (Without Docker)

#### 1. Setup PostgreSQL
```powershell
# Install PostgreSQL or use Docker
docker run -d --name cicd-postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:15

# Run schema
psql -U postgres -h localhost < infra/init.sql
```

#### 2. Setup Redis
```powershell
docker run -d --name cicd-redis -p 6379:6379 redis:7-alpine
```

#### 3. Backend
```powershell
cd backend
npm install
cp .env.example .env
# Edit .env if needed
npm run dev
```

#### 4. Worker
```powershell
cd worker
npm install
cp .env.example .env
# Edit .env if needed
npm run dev
```

#### 5. Frontend
```powershell
cd frontend
npm install
cp .env.example .env
# Edit .env if needed
npm run dev
```

## 📁 Project Structure

```
cicd-project/
├── backend/                 # Express API server
│   ├── src/routes/jenkins.ts  # Jenkins webhook endpoints
│   ├── src/
│   │   ├── routes/          # API route handlers
│   │   │   ├── pipelines.ts # Pipeline CRUD endpoints
│   │   │   └── runs.ts      # Run management endpoints
│   │   ├── config.ts        # Configuration
│   │   ├── db.ts            # PostgreSQL client
│   │   ├── redis.ts         # Redis clients
│   │   ├── logger.ts        # Winston logger
│   │   └── index.ts         # Server entry point
│   ├── Dockerfile
│   ├── package.json
│   └── tsconfig.json
│
├── worker/                  # Pipeline simulator
│   ├── src/
│   │   ├── config.ts        # Configuration
│   │   ├── db.ts            # Database client
│   │   ├── redis.ts         # Redis client
│   │   ├── logger.ts        # Logger
│   │   ├── simulator.ts     # Pipeline simulation logic
│   │   └── index.ts         # Worker entry point
│   ├── Dockerfile
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/                # React frontend
│   ├── src/
│   │   ├── components/      # React components
│   │   │   ├── RunsList.tsx         # Runs list view
│   │   │   ├── PipelineVisualizer.tsx # Stage/step visualization
│   │   │   └── LogsPanel.tsx        # Logs streaming panel
│   │   ├── hooks/
│   │   │   └── useWebSocket.ts      # WebSocket hook
│   │   ├── utils/
│   │   │   └── format.ts            # Formatting utilities
│   │   ├── api.ts           # API client
│   │   ├── config.ts        # Configuration
│   │   ├── types.ts         # TypeScript types
│   │   ├── App.tsx          # Main app component
│   │   └── main.tsx         # Entry point
│   ├── Dockerfile
│   ├── package.json
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   └── tsconfig.json
│
├── infra/
│   └── init.sql             # Database schema and seed data
│
├── jenkins/                 # Jenkins configuration
│   ├── casc.yaml            # Configuration as Code
│   ├── plugins.txt          # Plugin list
│   └── init.groovy.d/       # Initialization scripts
│
├── Jenkinsfile              # Pipeline definition for GitHub repos
├── docker-compose.yml       # Docker orchestration
├── README.md                # This file
├── JENKINS.md               # Jenkins integration guide
└── DEVELOPMENT.md           # Developer guide
```

## 🔌 API Endpoints

### Pipelines
- `GET /api/pipelines` - List all pipeline templates
- `GET /api/pipelines/:id` - Get pipeline by ID
- `POST /api/pipelines` - Create new pipeline template
- `DELETE /api/pipelines/:id` - Delete pipeline

### Runs
- `GET /api/runs` - List runs (supports filtering)
  - Query params: `status`, `repo`, `branch`, `limit`, `offset`
- `GET /api/runs/:id` - Get run details with steps
- `POST /api/runs` - Create and start a new run
- `POST /api/runs/:id/cancel` - Cancel a running pipeline
- `POST /api/runs/:id/rerun` - Re-run a pipeline with same parameters

### WebSocket Events
**Server → Client:**
- `run:status` - Run status update
- `run:step:update` - Step status update
- `run:log` - Log line emitted

**Client → Server:**
- `subscribe` - Subscribe to run updates
- `unsubscribe` - Unsubscribe from run updates

## 🗄️ Database Schema

### Tables
- **pipelines** - Pipeline templates with stages/steps configuration
- **runs** - Pipeline run instances
- **steps** - Individual steps within a run
- **logs** - Structured log entries (optional persistence)

See `infra/init.sql` for complete schema.

## 🎨 UI Components

### RunsList
Displays recent pipeline runs with:
- Status badges (queued, running, success, failed, cancelled)
- Repository and branch information
- Triggered by user
- Duration and timestamps

### PipelineVisualizer
Visual representation of pipeline stages:
- Organized by stage groups
- Color-coded step status
- Duration display per step
- Progress indicators

### LogsPanel
Real-time streaming log viewer:
- Auto-scroll capability
- Color-coded log levels (info, warn, error)
- Timestamp display
- Monospaced font for readability

## ⚙️ Configuration

### Environment Variables

**Backend** (`backend/.env`)
```env
PORT=4000
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=cicd_dashboard
REDIS_HOST=localhost
REDIS_PORT=6379
```

**Worker** (`worker/.env`)
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=cicd_dashboard
REDIS_HOST=localhost
REDIS_PORT=6379
FAILURE_RATE=0.1          # 10% failure rate for simulations
MIN_LOG_LINES=5
MAX_LOG_LINES=15
MIN_STEP_DURATION=2000    # milliseconds
MAX_STEP_DURATION=8000
```

**Frontend** (`frontend/.env`)
```env
VITE_API_URL=http://localhost:4000
VITE_WS_URL=http://localhost:4000
```

## 🧪 Testing the Application

### Option 1: Use Jenkins (Real Pipelines)

1. **Access Jenkins**: http://localhost:8080 (admin/admin123)
2. **Run Sample Pipeline**: Click "sample-pipeline" → "Build Now"
3. **Watch in Dashboard**: http://localhost:3000
4. **See real-time logs** streaming from Jenkins!

📖 **Full Jenkins Setup Guide**: See [JENKINS.md](JENKINS.md)

### Option 2: Use Simulator (Quick Test)

#### 1. Start a Pipeline Run
Click one of the pipeline buttons in the header or use the API:

```powershell
curl -X POST http://localhost:4000/api/runs -H "Content-Type: application/json" -d '{\"pipelineId\": 1, \"repo\": \"example/repo\", \"branch\": \"main\", \"triggeredBy\": \"manual\"}'
```

### 2. Watch Real-time Updates
- Select the run from the left sidebar
- Watch the pipeline stages update in real-time
- View live streaming logs in the logs panel

### 3. Cancel a Running Pipeline
Click the "Cancel" button on a running pipeline or use the API:

```powershell
curl -X POST http://localhost:4000/api/runs/1/cancel
```

### 4. Re-run a Pipeline
Click the "Rerun" button to execute the pipeline again with the same parameters.

## 🚀 Production Deployment

### Docker Production Build

1. **Build images**
```powershell
docker-compose build
```

2. **Push to registry**
```powershell
docker tag cicd-project-backend your-registry/cicd-backend:latest
docker tag cicd-project-worker your-registry/cicd-worker:latest
docker tag cicd-project-frontend your-registry/cicd-frontend:latest

docker push your-registry/cicd-backend:latest
docker push your-registry/cicd-worker:latest
docker push your-registry/cicd-frontend:latest
```

### Kubernetes Deployment (Future)
- Create Kubernetes manifests for each service
- Use ConfigMaps for environment variables
- Use Secrets for sensitive data
- Set up Ingress for external access
- Configure horizontal pod autoscaling for workers

## 📊 Monitoring & Observability

### Logs
All services use structured logging with Winston:
```powershell
# View backend logs
docker-compose logs -f backend

# View worker logs
docker-compose logs -f worker
```

### Health Checks
- Backend: `GET /health`
- Database: Built-in health checks in docker-compose
- Redis: Built-in health checks in docker-compose

## 🔧 Troubleshooting

### Services won't start
```powershell
# Check service status
docker-compose ps

# View logs for errors
docker-compose logs

# Restart services
docker-compose restart
```

### Database connection issues
```powershell
# Check if PostgreSQL is ready
docker-compose exec db pg_isready -U postgres

# Manually connect to database
docker-compose exec db psql -U postgres -d cicd_dashboard
```

### Redis connection issues
```powershell
# Test Redis connection
docker-compose exec redis redis-cli ping
```

### Frontend can't connect to backend
- Verify `VITE_API_URL` and `VITE_WS_URL` in frontend/.env
- Check if backend is running: `curl http://localhost:4000/health`
- Check browser console for CORS errors

### Worker not processing jobs
```powershell
# Check worker logs
docker-compose logs -f worker

# Verify Redis queue
docker-compose exec redis redis-cli LLEN run-queue
```

## 🛣️ Roadmap

### Phase 1 (Current MVP)
- ✅ Core pipeline simulation
- ✅ Real-time log streaming
- ✅ Basic UI with run history

### Phase 2 ⭐ (Jenkins Integration - COMPLETED!)
- [x] Jenkins server integration
- [x] Real pipeline execution from GitHub
- [x] GitHub webhook support
- [x] Jenkins API integration
- [ ] Authentication & Authorization (JWT)
- [ ] User management and RBAC
- [ ] Pipeline templates UI editor
- [ ] Test results parsing and visualization
- [ ] Artifacts storage (S3 integration)

### Phase 3
- [ ] Real pipeline execution (Docker/Kubernetes)
- [ ] GitHub/GitLab webhook integration
- [ ] Notifications (Email, Slack)
- [ ] Advanced filtering and search
- [ ] Dashboard analytics and metrics

### Phase 4
- [ ] Multi-tenancy support
- [ ] Audit logging
- [ ] Performance metrics (Prometheus)
- [ ] Cost tracking
- [ ] Pipeline scheduling (cron)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 👥 Authors

Created as a demonstration CI/CD Pipeline Dashboard.

## 🙏 Acknowledgments

- Socket.IO for real-time communication
- React Query for excellent data management
- Tailwind CSS for beautiful styling
- Lucide for icons
- The open-source community

---

**Built with ❤️ using React, Node.js, PostgreSQL, and Redis**
