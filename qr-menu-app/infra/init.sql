-- ============================================
-- QR Menu App - Database Initialization Script
-- PostgreSQL 16+
-- ============================================

-- Create ENUM types
CREATE TYPE session_status AS ENUM ('active', 'closed', 'paid', 'cancelled');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'served', 'cancelled');
CREATE TYPE option_type AS ENUM ('single_select', 'multi_select');
CREATE TYPE payment_method AS ENUM ('credit_card', 'debit_card', 'digital_wallet', 'cash');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE sync_operation AS ENUM ('create', 'update', 'delete');
CREATE TYPE sync_status AS ENUM ('pending', 'synced', 'failed');

-- ============================================
-- CORE TABLES (Non-sharded, system-wide)
-- ============================================

CREATE TABLE restaurants (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    api_key VARCHAR(255) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    timezone VARCHAR(50) DEFAULT 'UTC',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_restaurants_slug ON restaurants(slug);
CREATE INDEX idx_restaurants_api_key ON restaurants(api_key);

-- ============================================
-- SHARDED TABLES (Per restaurant database)
-- ============================================

CREATE TABLE tables (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    table_number VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(restaurant_id, table_number),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE INDEX idx_tables_restaurant ON tables(restaurant_id);

-- QR codes linked to tables (static, long-lived)
CREATE TABLE qr_codes (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    table_id BIGINT NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    qr_data TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (table_id) REFERENCES tables(id) ON DELETE CASCADE
);

CREATE INDEX idx_qr_codes_token ON qr_codes(token);
CREATE INDEX idx_qr_codes_table ON qr_codes(table_id);

-- Session management (isolates orders per visit)
CREATE TABLE sessions (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    table_id BIGINT NOT NULL,
    qr_code_id BIGINT,
    session_pin VARCHAR(6) NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    status session_status DEFAULT 'active',
    num_diners INT DEFAULT 1,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    closed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (table_id) REFERENCES tables(id) ON DELETE CASCADE,
    FOREIGN KEY (qr_code_id) REFERENCES qr_codes(id) ON DELETE SET NULL
);

CREATE INDEX idx_sessions_restaurant_status ON sessions(restaurant_id, status);
CREATE INDEX idx_sessions_token ON sessions(session_token);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);
CREATE INDEX idx_sessions_table_active ON sessions(table_id, status);

-- Users (diners per session)
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    name VARCHAR(255),
    diner_sequence INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
);

CREATE INDEX idx_users_session ON users(session_id);

-- Menu categories
CREATE TABLE menu_categories (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE INDEX idx_menu_categories_restaurant ON menu_categories(restaurant_id, is_active);

-- Menu items (with caching-friendly fields)
CREATE TABLE menu_items (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    is_available BOOLEAN DEFAULT true,
    photo_url VARCHAR(500),
    dietary_info VARCHAR(255),
    sort_order INT DEFAULT 0,
    cache_version INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES menu_categories(id) ON DELETE CASCADE
);

CREATE INDEX idx_menu_items_restaurant_available ON menu_items(restaurant_id, is_available);
CREATE INDEX idx_menu_items_category ON menu_items(category_id);

-- Menu item customization options (e.g., Size, Spice Level)
CREATE TABLE menu_item_options (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    menu_item_id BIGINT NOT NULL,
    option_name VARCHAR(255) NOT NULL,
    option_type option_type DEFAULT 'single_select',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE
);

CREATE INDEX idx_menu_item_options_item ON menu_item_options(menu_item_id);

-- Option values (e.g., "Small", "Medium", "Large")
CREATE TABLE menu_item_option_values (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    option_id BIGINT NOT NULL,
    value VARCHAR(255) NOT NULL,
    price_modifier DECIMAL(10, 2) DEFAULT 0,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (option_id) REFERENCES menu_item_options(id) ON DELETE CASCADE
);

CREATE INDEX idx_option_values_option ON menu_item_option_values(option_id);

-- Orders (immutable after creation)
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    user_id BIGINT,
    order_number INT NOT NULL,
    status order_status DEFAULT 'pending',
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0,
    tax DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_orders_session_status ON orders(session_id, status);
CREATE INDEX idx_orders_restaurant_created ON orders(restaurant_id, created_at);
CREATE INDEX idx_orders_status ON orders(status);

-- Order line items (immutable)
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    menu_item_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE RESTRICT
);

CREATE INDEX idx_order_items_order ON order_items(order_id);

-- Order item customizations (e.g., "Large" size, "Extra spice")
CREATE TABLE order_item_customizations (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    order_item_id BIGINT NOT NULL,
    option_name VARCHAR(255) NOT NULL,
    option_value VARCHAR(255) NOT NULL,
    price_modifier DECIMAL(10, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE CASCADE
);

CREATE INDEX idx_customizations_order_item ON order_item_customizations(order_item_id);

-- Payments
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method payment_method NOT NULL,
    payment_gateway_id VARCHAR(255),
    status payment_status DEFAULT 'pending',
    receipt_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
);

CREATE INDEX idx_payments_session ON payments(session_id);
CREATE INDEX idx_payments_status ON payments(status);

-- ============================================
-- AUDIT & RESILIENCE TABLES
-- ============================================

-- Order status history (for tracking and audit trail)
CREATE TABLE order_status_history (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(255),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE INDEX idx_order_history_order ON order_status_history(order_id);
CREATE INDEX idx_order_history_changed_at ON order_status_history(changed_at);

-- Sync queue for offline-first features and conflict resolution
CREATE TABLE sync_queue (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id BIGINT NOT NULL,
    operation sync_operation NOT NULL,
    payload JSONB NOT NULL,
    device_id VARCHAR(255),
    status sync_status DEFAULT 'pending',
    retry_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    synced_at TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE INDEX idx_sync_queue_status ON sync_queue(status);
CREATE INDEX idx_sync_queue_restaurant ON sync_queue(restaurant_id, status);
CREATE INDEX idx_sync_queue_created ON sync_queue(created_at);

-- Session activity log for debugging and analytics
CREATE TABLE session_activity_log (
    id BIGSERIAL PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    action VARCHAR(100) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
);

CREATE INDEX idx_session_activity_session ON session_activity_log(session_id);
CREATE INDEX idx_session_activity_created ON session_activity_log(created_at);

-- ============================================
-- SEED DATA
-- ============================================

-- Insert default restaurant
INSERT INTO restaurants (name, slug, api_key, is_active, timezone)
VALUES (
    'Demo Restaurant',
    'demo-restaurant',
    'sk_demo_' || encode(gen_random_bytes(16), 'hex'),
    true,
    'UTC'
) ON CONFLICT (slug) DO NOTHING;

-- Get the restaurant ID
DO $$
DECLARE
    restaurant_id BIGINT;
BEGIN
    SELECT id INTO restaurant_id FROM restaurants WHERE slug = 'demo-restaurant' LIMIT 1;
    
    IF restaurant_id IS NOT NULL THEN
        -- Insert sample tables
        INSERT INTO tables (restaurant_id, table_number, capacity, is_active, location)
        VALUES 
            (restaurant_id, '1', 4, true, 'Window Seat'),
            (restaurant_id, '2', 2, true, 'Bar'),
            (restaurant_id, '3', 6, true, 'Patio'),
            (restaurant_id, '4', 4, true, 'Corner')
        ON CONFLICT DO NOTHING;

        -- Insert menu categories
        INSERT INTO menu_categories (restaurant_id, name, description, sort_order, is_active)
        VALUES
            (restaurant_id, 'Appetizers', 'Start your meal', 1, true),
            (restaurant_id, 'Mains', 'Main courses', 2, true),
            (restaurant_id, 'Desserts', 'Sweet treats', 3, true),
            (restaurant_id, 'Beverages', 'Drinks', 4, true)
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- ============================================
-- PERFORMANCE OPTIMIZATIONS
-- ============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create partial indexes for active sessions (commonly queried)
CREATE INDEX idx_sessions_active ON sessions(restaurant_id) WHERE status = 'active';

-- Create partial index for available items (commonly used in menu queries)
CREATE INDEX idx_menu_items_available_category ON menu_items(category_id) WHERE is_available = true;

-- Analyze tables for query planning
ANALYZE;
