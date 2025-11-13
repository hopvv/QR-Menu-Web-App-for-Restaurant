# Infrastructure Setup Guide

## Overview

This infrastructure uses **PostgreSQL** with a scalable, sharded database design to support:
- 1000+ concurrent users per restaurant
- 1000 restaurants system-wide
- Real-time order processing with WebSocket support
- Offline-first capabilities with sync queue
- Immutable order data for audit trails

## Architecture Components

### Database (PostgreSQL)
- **Why PostgreSQL?** 
  - ACID compliance for financial transactions
  - Advanced indexing and query optimization
  - Native JSON support (JSONB) for flexible sync payloads
  - Horizontal sharding capability by restaurant
  - Connection pooling support
  - Strong consistency guarantees

### Cache Layer (Redis)
- Real-time order status updates
- Session data caching
- Menu availability caching
- Rate limiting
- WebSocket message queue

### Services
- **Web**: React-based customer ordering interface
- **Server**: Node.js/TypeScript backend with Express

## Database Schema Design

### Key Design Principles

1. **Restaurant Sharding**: Every table includes `restaurant_id` as first foreign key
   - Enables horizontal scaling
   - Supports data isolation per restaurant
   - Simplifies backup and disaster recovery

2. **Session Isolation**: Orders are grouped by session with expiry
   - Multiple diners per table share one session
   - PIN-based access control
   - Automatic cleanup via `expires_at`

3. **Immutable Orders**: Order data never changes after creation
   - Only status updates allowed
   - Full audit trail via `order_status_history`
   - PCI compliance friendly

4. **Strategic Indexing**: Multi-column indexes for common queries
   ```sql
   -- Active sessions lookup (most common)
   idx_sessions_restaurant_status(restaurant_id, status)
   
   -- Order retrieval by session
   idx_orders_session_status(session_id, status)
   
   -- Menu availability
   idx_menu_items_restaurant_available(restaurant_id, is_available)
   ```

### Table Structure

**Core Tables:**
- `restaurants`: System-wide restaurant registry
- `tables`: Physical dining tables
- `qr_codes`: Static QR codes linking to tables

**Session Management:**
- `sessions`: Groups orders per table visit with PIN security
- `users`: Individual diners within a session

**Menu:**
- `menu_categories`: Food categories
- `menu_items`: Individual dishes
- `menu_item_options`: Customization options (Size, Spice, etc.)
- `menu_item_option_values`: Option choices with price modifiers

**Orders:**
- `orders`: Order header with totals
- `order_items`: Line items in order
- `order_item_customizations`: Customer selections for options

**Payments:**
- `payments`: Payment records (PCI compliant)

**Audit & Resilience:**
- `order_status_history`: Complete order lifecycle tracking
- `sync_queue`: Offline changes queued for sync
- `session_activity_log`: Debugging and analytics

## Getting Started

### Prerequisites
- Docker & Docker Compose
- Node.js 24+ (for local development)
- PostgreSQL 16 client tools (optional, for local DB access)

### Starting the Stack

```bash
# Navigate to the project root
cd qr-menu-app

# Set up environment variables
cp infra/.env.example .env

# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f server

# Run database migrations (if needed)
docker-compose exec db psql -U qr_menu_user -d qr_menu_db < infra/init.sql
```

### Verify Services

```bash
# Check all containers are running
docker-compose ps

# Test PostgreSQL connection
docker-compose exec db psql -U qr_menu_user -d qr_menu_db -c "SELECT COUNT(*) FROM restaurants;"

# Test Redis connection
docker-compose exec redis redis-cli ping

# Test API health
curl http://localhost:5000/health

# Test Web app
open http://localhost:3000
```

## Development (hot-reload)

- Purpose: Run the stack with the frontend and server mounted from your host so code changes trigger hot-reload.
- Command: `docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build`
- Notes:
  - `web` dev server is exposed on `http://localhost:3000` (Vite HMR).
  - `server` dev server is exposed on `http://localhost:5001` (ts-node-dev).
  - On macOS file watching inside Docker can be unreliable. If HMR doesn't pick changes, enable polling:
    - `CHOKIDAR_USEPOLLING=true docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build`
  - `infra/docker-compose.dev.yml` mounts your local `server` and `web` folders into the containers; run `npm install` in `server` and `web` locally before starting.
  - Alternative: add `@types/node` to `web` devDependencies and use `import.meta.env` values in `vite.config.ts` instead of `process.env`.

**Recommended: Run web and server locally for faster iteration**

For easier debugging and faster hot-reload, run the web app and server on your local machine (not in Docker) while keeping the database in Docker:

```bash
# See LOCAL_DEV.md in the project root for complete instructions
```### Environment Configuration

Copy `.env.example` to `.env` and update values:

```bash
# PostgreSQL
DATABASE_URL=postgresql://qr_menu_user:password@db:5432/qr_menu_db
DATABASE_POOL_MIN=5          # Connection pool minimum
DATABASE_POOL_MAX=20         # Connection pool maximum

# Redis
REDIS_URL=redis://redis:6379

# Security
JWT_SECRET=your-secure-random-string

# Session
SESSION_EXPIRY_MINUTES=120
PIN_LENGTH=6
```

## Scalability Considerations

### Horizontal Scaling
1. **Database Sharding**: Partition by `restaurant_id`
   ```sql
   -- Example: Restaurant-specific shard
   SELECT * FROM restaurants WHERE id = 1;
   -- All other tables filtered by restaurant_id
   ```

2. **Read Replicas**: Set up PostgreSQL streaming replication
   - Primary: Write operations
   - Replicas: Read-heavy queries (analytics, reporting)

3. **Cache Invalidation**: Use Redis for cache invalidation signals
   ```javascript
   // When menu changes
   redis.publish('menu:invalidate', restaurantId);
   ```

### Performance Optimizations

1. **Connection Pooling**: PgBouncer or pg-pool
   - Min connections: 5
   - Max connections: 20
   - Per server instance

2. **Query Optimization**:
   ```sql
   -- Partial indexes for active sessions
   CREATE INDEX idx_sessions_active 
   ON sessions(restaurant_id) 
   WHERE status = 'active';
   
   -- Multi-column indexes for common joins
   CREATE INDEX idx_orders_session_status 
   ON orders(session_id, status);
   ```

3. **Menu Caching**: Cache entire menu per restaurant
   ```javascript
   // Menu changes increment cache_version
   UPDATE menu_items SET cache_version = cache_version + 1 WHERE restaurant_id = 1;
   
   // Clients detect version change and refetch
   ```

### Monitoring & Maintenance

```bash
# Monitor database performance
docker-compose exec db psql -U qr_menu_user -d qr_menu_db -c "
  SELECT schemaname, tablename, idx_scan, idx_tup_read
  FROM pg_stat_user_indexes
  ORDER BY idx_scan DESC;"

# Check table sizes
docker-compose exec db psql -U qr_menu_user -d qr_menu_db -c "
  SELECT tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
  FROM pg_tables
  WHERE schemaname != 'pg_catalog'
  ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;"

# Vacuum and analyze
docker-compose exec db psql -U qr_menu_user -d qr_menu_db -c "VACUUM ANALYZE;"
```

## Disaster Recovery

### Backup Strategy

```bash
# Full backup
docker-compose exec db pg_dump -U qr_menu_user qr_menu_db > backup.sql

# Restore from backup
docker-compose exec db psql -U qr_menu_user qr_menu_db < backup.sql
```

### Automated Backups
Add to crontab for daily backups:
```bash
0 2 * * * docker-compose exec db pg_dump -U qr_menu_user qr_menu_db > /backups/qr_menu_db_$(date +\%Y\%m\%d).sql
```

## Production Deployment

### Pre-Production Checklist
- [ ] Change all default passwords
- [ ] Set strong JWT_SECRET
- [ ] Configure Redis persistence
- [ ] Set up automated backups
- [ ] Enable database logging
- [ ] Configure connection pooling for high load
- [ ] Set up monitoring (DataDog, New Relic, etc.)
- [ ] Configure log aggregation (ELK Stack)
- [ ] Set up alerting for failed payments/orders

### Kubernetes Deployment
Add `k8s/` directory with:
- StatefulSet for PostgreSQL with persistent volumes
- Deployment for Redis
- Deployment for API server
- Deployment for Web app
- ConfigMaps for environment variables
- Secrets for sensitive data
- Services and Ingress configuration

## Troubleshooting

### Database Connection Issues
```bash
# Test PostgreSQL connectivity
docker-compose exec server psql postgresql://qr_menu_user:password@db:5432/qr_menu_db -c "SELECT 1"

# Check database logs
docker-compose logs db
```

### Redis Connection Issues
```bash
# Test Redis connectivity
docker-compose exec server redis-cli -h redis ping

# Check Redis logs
docker-compose logs redis
```

### API Server Issues
```bash
# Check server logs
docker-compose logs -f server

# View environment variables being used
docker-compose exec server env | grep DATABASE
```

### Performance Issues
1. Check slow queries:
   ```sql
   SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;
   ```

2. Check missing indexes:
   ```sql
   SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0;
   ```

3. Check table statistics:
   ```sql
   SELECT * FROM pg_stat_user_tables;
   ```

## Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Node.js Database Libraries](https://node-postgres.com/)
