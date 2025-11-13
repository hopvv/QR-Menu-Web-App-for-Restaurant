# Local Development Setup (Web + Server)

Run the web app and server locally for easy debugging. The PostgreSQL database runs in Docker.

## Prerequisites

- Node.js 24+
- Docker (for the database only)
- Database running in Docker (see below)

## Quick Start

### 1. Ensure the database is running

```bash
cd qr-menu-app/infra
docker compose up -d db
# Verify it's running:
docker compose ps
```

You should see:
```
infra-db-1  postgres:16-alpine  Up X seconds (healthy)  0.0.0.0:5432->5432/tcp
```

### 2. Start the server (in Terminal 1)

```bash
cd qr-menu-app/server

# Create .env for local development
cat > .env << 'EOF'
NODE_ENV=development
PORT=5000
DATABASE_URL=postgresql://qr_menu_user:qr_menu_password@localhost:5432/qr_menu_db
DATABASE_POOL_MIN=5
DATABASE_POOL_MAX=20
JWT_SECRET=your-secret-key-change-in-production
EOF

# Install dependencies (if not done yet)
npm install

# Start with hot-reload
npm run dev
```

You should see:
```
✓ Server is running on http://localhost:5000
✓ Environment: development
```

### 3. Start the web app (in Terminal 2)

```bash
cd qr-menu-app/web

# Install dependencies (if not done yet)
npm install

# Start Vite dev server with hot-reload
npm start
```

You should see:
```
VITE v5.x.x  ready in XXX ms

➜  Local:   http://localhost:5173/
➜  press h to show help
```

### 4. Open in your browser

Visit: **http://localhost:5173**

The web app will automatically fetch from `http://localhost:5000/api/menu`.

## Debugging

### Browser DevTools (for web issues)

1. Open DevTools: `F12` or `Cmd+Option+I` (macOS)
2. **Console** tab: See errors and logs
3. **Network** tab: Watch API requests to `http://localhost:5000/api/menu`
4. **Application** tab: Check cached data

### Server Logs

Watch the terminal running `npm run dev` in the `server` directory.

Example output:
```
GET /api/menu 200
POST /api/admin/items 201
ERROR: Connection failed: ...
```

### Test API Endpoints Directly

```bash
# Check server health
curl http://localhost:5000/health

# Get menu items
curl http://localhost:5000/api/menu

# Get menu for a specific restaurant
curl "http://localhost:5000/api/menu?restaurantId=1"
```

## Hot-Reload

- **Server**: Changes to `server/src/**/*.ts` auto-reload (ts-node-dev)
- **Web**: Changes to `web/src/**/*.tsx` auto-hot-reload in the browser (Vite)

No manual restart needed!

## Stopping Services

```bash
# Stop the database (when done developing)
cd qr-menu-app/infra
docker compose stop db

# Or stop and remove (data is persisted in volumes)
cd qr-menu-app/infra
docker compose down
```

## Troubleshooting

### "Cannot connect to database"
- Confirm DB is running: `docker compose ps` in `infra/`
- Confirm the `.env` file in `server/` has the correct `DATABASE_URL`
- Confirm port 5432 is exposed: `docker compose ps` should show `0.0.0.0:5432->5432/tcp`

### "Port 5000 is already in use"
- Check what's using port 5000: `lsof -i :5000`
- Kill it: `kill -9 <PID>`
- Or change `PORT` in `server/.env` to `5001` or another port, then update `web/src/hooks/useFetch.ts`

### "Port 5173 is already in use"
- Vite will auto-increment to 5174, 5175, etc. (check terminal output)
- Or kill the process using port 5173: `lsof -i :5173`

### API returns "Error loading menu"
- Check browser console for the exact error
- Verify server is running: `curl http://localhost:5000/health`
- Verify web app is calling the right API URL: check `web/src/hooks/useFetch.ts`

### Changes in server code don't reload
- Verify `npm run dev` is running (not `npm start`)
- Check for TypeScript errors: `npx tsc --noEmit` in `server/`
- Restart `npm run dev`

### Changes in web code don't hot-reload
- Verify `npm start` is running (not `npm run build`)
- Check browser console for errors
- Verify the file is saved

## Running Everything in Docker (Alternative)

If you prefer to run everything in Docker for consistency:

```bash
cd qr-menu-app/infra
docker compose down  # Stop current containers
docker compose up --build  # Rebuild and start all (web, server, db)
# Visit http://localhost:3000
```

But local dev is recommended for faster iteration and easier debugging!
