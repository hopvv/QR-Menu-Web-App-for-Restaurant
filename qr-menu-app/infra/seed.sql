-- ============================================
-- QR Menu App - Database Seeding Script
-- This script is idempotent and safe to run multiple times.
-- ============================================

DO $$
DECLARE
    -- Restaurant ID
    v_restaurant_id BIGINT;
    
    -- Table IDs
    v_table_1_id BIGINT;
    v_table_2_id BIGINT;

    -- Category UUIDs
    v_cat_appetizers_id UUID;
    v_cat_mains_id UUID;
    v_cat_desserts_id UUID;
    v_cat_beverages_id UUID;

    -- Menu Item UUIDs
    v_item_spring_rolls_id UUID;
    v_item_calamari_id UUID;
    v_item_salmon_id UUID;
    v_item_ribeye_id UUID;
    v_item_carbonara_id UUID;
    v_item_tiramisu_id UUID;
    v_item_lava_cake_id UUID;
    v_item_espresso_id UUID;
    v_item_cappuccino_id UUID;
    v_item_iced_tea_id UUID;
    v_item_burger_id UUID; -- New item
    v_item_salad_id UUID;  -- New item

    -- Option UUIDs
    v_option_salmon_size_id UUID;
    v_option_ribeye_temp_id UUID;
    v_option_cappuccino_size_id UUID;
    v_option_burger_cheese_id UUID; -- New option
    v_option_burger_patty_id UUID;  -- New option

    -- Session UUIDs
    v_session_1_id UUID;
    v_session_2_id UUID;

    -- User UUIDs
    v_user_1_session_1_id UUID;
    v_user_2_session_1_id UUID;
    v_user_1_session_2_id UUID;

    -- Order UUIDs
    v_order_1_session_1_id UUID;
    v_order_2_session_1_id UUID;
    v_order_1_session_2_id UUID;

BEGIN
    -- Ensure the demo restaurant exists and get its ID.
    INSERT INTO restaurants (name, slug, api_key, is_active, timezone) 
    VALUES ('Demo Restaurant', 'demo-restaurant', 'sk_demo_test123', true, 'UTC')
    ON CONFLICT (slug) DO UPDATE SET api_key = 'sk_demo_test123'
    RETURNING id INTO v_restaurant_id;

    IF v_restaurant_id IS NULL THEN
        SELECT id INTO v_restaurant_id FROM restaurants WHERE slug = 'demo-restaurant';
    END IF;

    IF v_restaurant_id IS NULL THEN
        RAISE EXCEPTION 'Could not find or create the demo restaurant.';
    END IF;

    -- Insert sample tables
    INSERT INTO tables (restaurant_id, table_number, capacity, is_active, location) 
    VALUES 
      (v_restaurant_id, '1', 4, true, 'Window Seat'),
      (v_restaurant_id, '2', 2, true, 'Bar'),
      (v_restaurant_id, '3', 6, true, 'Patio'),
      (v_restaurant_id, '4', 4, true, 'Corner')
    ON CONFLICT (restaurant_id, table_number) DO NOTHING;

    SELECT id INTO v_table_1_id FROM tables WHERE restaurant_id = v_restaurant_id AND table_number = '1';
    SELECT id INTO v_table_2_id FROM tables WHERE restaurant_id = v_restaurant_id AND table_number = '2';

    -- Insert menu categories and capture their new UUIDs
    INSERT INTO menu_categories (restaurant_id, name, description, sort_order, is_active)
    VALUES
      (v_restaurant_id, 'Appetizers', 'Start your meal', 1, true),
      (v_restaurant_id, 'Mains', 'Main courses', 2, true),
      (v_restaurant_id, 'Desserts', 'Sweet treats', 3, true),
      (v_restaurant_id, 'Beverages', 'Drinks', 4, true)
    ON CONFLICT (restaurant_id, name) DO NOTHING;

    SELECT id INTO v_cat_appetizers_id FROM menu_categories WHERE restaurant_id = v_restaurant_id AND name = 'Appetizers';
    SELECT id INTO v_cat_mains_id FROM menu_categories WHERE restaurant_id = v_restaurant_id AND name = 'Mains';
    SELECT id INTO v_cat_desserts_id FROM menu_categories WHERE restaurant_id = v_restaurant_id AND name = 'Desserts';
    SELECT id INTO v_cat_beverages_id FROM menu_categories WHERE restaurant_id = v_restaurant_id AND name = 'Beverages';

    -- Insert sample menu items using the category UUIDs
    INSERT INTO menu_items (restaurant_id, category_id, name, description, price, is_available, photo_url, sort_order)
    VALUES
      (v_restaurant_id, v_cat_appetizers_id, 'Spring Rolls', 'Crispy spring rolls with sweet dipping sauce', 8.99, true, 'https://via.placeholder.com/300x200/FF5733/FFFFFF?text=Spring+Rolls', 1),
      (v_restaurant_id, v_cat_appetizers_id, 'Calamari Fritti', 'Golden fried squid rings with marinara', 12.99, true, 'https://via.placeholder.com/300x200/FFC300/000000?text=Calamari', 2),
      (v_restaurant_id, v_cat_mains_id, 'Grilled Salmon', 'Fresh Atlantic salmon with lemon butter sauce and asparagus', 24.99, true, 'https://via.placeholder.com/300x200/DAF7A6/000000?text=Salmon', 1),
      (v_restaurant_id, v_cat_mains_id, 'Ribeye Steak', 'Premium 14oz ribeye, cooked to your preference', 34.99, true, 'https://via.placeholder.com/300x200/C70039/FFFFFF?text=Ribeye', 2),
      (v_restaurant_id, v_cat_mains_id, 'Pasta Carbonara', 'Classic Roman pasta with pancetta, egg yolk, and Pecorino Romano', 16.99, true, 'https://via.placeholder.com/300x200/900C3F/FFFFFF?text=Carbonara', 3),
      (v_restaurant_id, v_cat_mains_id, 'Veggie Burger', 'Plant-based patty with lettuce, tomato, onion, and pickles', 15.50, true, 'https://via.placeholder.com/300x200/581845/FFFFFF?text=Veggie+Burger', 4), -- New
      (v_restaurant_id, v_cat_mains_id, 'Caesar Salad', 'Crisp romaine, croutons, Parmesan, and Caesar dressing', 11.00, true, 'https://via.placeholder.com/300x200/FF5733/FFFFFF?text=Caesar+Salad', 5), -- New
      (v_restaurant_id, v_cat_desserts_id, 'Tiramisu', 'Traditional Italian coffee-flavored dessert', 9.99, true, 'https://via.placeholder.com/300x200/FFC300/000000?text=Tiramisu', 1),
      (v_restaurant_id, v_cat_desserts_id, 'Chocolate Lava Cake', 'Warm chocolate cake with molten center, served with vanilla ice cream', 8.99, true, 'https://via.placeholder.com/300x200/DAF7A6/000000?text=Lava+Cake', 2),
      (v_restaurant_id, v_cat_beverages_id, 'Espresso', 'Single or double shot of rich espresso', 3.99, true, 'https://via.placeholder.com/300x200/C70039/FFFFFF?text=Espresso', 1),
      (v_restaurant_id, v_cat_beverages_id, 'Cappuccino', 'Rich and creamy cappuccino with frothed milk', 5.99, true, 'https://via.placeholder.com/300x200/900C3F/FFFFFF?text=Cappuccino', 2),
      (v_restaurant_id, v_cat_beverages_id, 'Iced Tea', 'Fresh brewed iced tea, unsweetened', 4.99, true, 'https://via.placeholder.com/300x200/581845/FFFFFF?text=Iced+Tea', 3)
    ON CONFLICT (restaurant_id, name) DO NOTHING;

    -- Get IDs for items that will have options
    SELECT id INTO v_item_spring_rolls_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Spring Rolls';
    SELECT id INTO v_item_calamari_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Calamari Fritti';
    SELECT id INTO v_item_salmon_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Grilled Salmon';
    SELECT id INTO v_item_ribeye_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Ribeye Steak';
    SELECT id INTO v_item_carbonara_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Pasta Carbonara';
    SELECT id INTO v_item_burger_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Veggie Burger';
    SELECT id INTO v_item_salad_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Caesar Salad';
    SELECT id INTO v_item_tiramisu_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Tiramisu';
    SELECT id INTO v_item_lava_cake_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Chocolate Lava Cake';
    SELECT id INTO v_item_espresso_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Espresso';
    SELECT id INTO v_item_cappuccino_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Cappuccino';
    SELECT id INTO v_item_iced_tea_id FROM menu_items WHERE restaurant_id = v_restaurant_id AND name = 'Iced Tea';

    -- Add menu item options
    INSERT INTO menu_item_options (restaurant_id, menu_item_id, option_name, option_type)
    VALUES
      (v_restaurant_id, v_item_salmon_id, 'Size', 'single_select'),
      (v_restaurant_id, v_item_ribeye_id, 'Temperature', 'single_select'),
      (v_restaurant_id, v_item_cappuccino_id, 'Size', 'single_select'),
      (v_restaurant_id, v_item_burger_id, 'Cheese', 'single_select'), -- New
      (v_restaurant_id, v_item_burger_id, 'Patty Type', 'single_select') -- New
    ON CONFLICT (menu_item_id, option_name) DO NOTHING;

    -- Get IDs for the options we just created
    SELECT id INTO v_option_salmon_size_id FROM menu_item_options WHERE menu_item_id = v_item_salmon_id AND option_name = 'Size';
    SELECT id INTO v_option_ribeye_temp_id FROM menu_item_options WHERE menu_item_id = v_item_ribeye_id AND option_name = 'Temperature';
    SELECT id INTO v_option_cappuccino_size_id FROM menu_item_options WHERE menu_item_id = v_item_cappuccino_id AND option_name = 'Size';
    SELECT id INTO v_option_burger_cheese_id FROM menu_item_options WHERE menu_item_id = v_item_burger_id AND option_name = 'Cheese';
    SELECT id INTO v_option_burger_patty_id FROM menu_item_options WHERE menu_item_id = v_item_burger_id AND option_name = 'Patty Type';

    -- Add option values
    INSERT INTO menu_item_option_values (restaurant_id, option_id, value, price_modifier, sort_order)
    VALUES
      (v_restaurant_id, v_option_salmon_size_id, 'Regular', 0, 1),
      (v_restaurant_id, v_option_salmon_size_id, 'Large', 5, 2),
      (v_restaurant_id, v_option_ribeye_temp_id, 'Rare', 0, 1),
      (v_restaurant_id, v_option_ribeye_temp_id, 'Medium Rare', 0, 2),
      (v_restaurant_id, v_option_ribeye_temp_id, 'Medium', 0, 3),
      (v_restaurant_id, v_option_ribeye_temp_id, 'Medium Well', 0, 4),
      (v_restaurant_id, v_option_ribeye_temp_id, 'Well Done', 0, 5),
      (v_restaurant_id, v_option_cappuccino_size_id, 'Small', 0, 1),
      (v_restaurant_id, v_option_cappuccino_size_id, 'Large', 1.50, 2),
      (v_restaurant_id, v_option_burger_cheese_id, 'Cheddar', 1.00, 1),
      (v_restaurant_id, v_option_burger_cheese_id, 'Swiss', 1.25, 2),
      (v_restaurant_id, v_option_burger_cheese_id, 'None', 0, 3),
      (v_restaurant_id, v_option_burger_patty_id, 'Beef', 2.00, 1),
      (v_restaurant_id, v_option_burger_patty_id, 'Chicken', 1.50, 2),
      (v_restaurant_id, v_option_burger_patty_id, 'Veggie', 0, 3)
    ON CONFLICT (option_id, value) DO NOTHING;

    -- ============================================
    -- Sample Sessions, Users, Orders, Payments
    -- ============================================

    -- Session 1: Active session at Table 1
    INSERT INTO sessions (restaurant_id, table_id, session_pin, session_token, status, num_diners, expires_at)
    VALUES (v_restaurant_id, v_table_1_id, '123456', 'token-table1-active', 'active', 2, CURRENT_TIMESTAMP + INTERVAL '2 hours')
    ON CONFLICT (session_token) DO UPDATE SET status = 'active', expires_at = CURRENT_TIMESTAMP + INTERVAL '2 hours'
    RETURNING id INTO v_session_1_id;

    -- Users for Session 1
    INSERT INTO users (restaurant_id, session_id, name, diner_sequence)
    VALUES
      (v_restaurant_id, v_session_1_id, 'Alice', 1),
      (v_restaurant_id, v_session_1_id, 'Bob', 2)
    ON CONFLICT (session_id, diner_sequence) DO NOTHING;

    SELECT id INTO v_user_1_session_1_id FROM users WHERE session_id = v_session_1_id AND diner_sequence = 1;
    SELECT id INTO v_user_2_session_1_id FROM users WHERE session_id = v_session_1_id AND diner_sequence = 2;

    -- Order 1 for Session 1 (by Alice)
    INSERT INTO orders (restaurant_id, session_id, user_id, order_number, status, subtotal, tax, total, special_instructions)
    VALUES (v_restaurant_id, v_session_1_id, v_user_1_session_1_id, 1, 'confirmed', 24.99, 2.00, 26.99, 'No onions on the side')
    ON CONFLICT (session_id, order_number) DO UPDATE SET status = 'confirmed'
    RETURNING id INTO v_order_1_session_1_id;

    INSERT INTO order_items (restaurant_id, order_id, menu_item_id, quantity, unit_price, subtotal, notes)
    VALUES
      (v_restaurant_id, v_order_1_session_1_id, v_item_salmon_id, 1, 24.99, 24.99, NULL);

    -- Order 2 for Session 1 (by Bob)
    INSERT INTO orders (restaurant_id, session_id, user_id, order_number, status, subtotal, tax, total, special_instructions)
    VALUES (v_restaurant_id, v_session_1_id, v_user_2_session_1_id, 2, 'preparing', 16.99, 1.36, 18.35, NULL)
    ON CONFLICT (session_id, order_number) DO UPDATE SET status = 'preparing'
    RETURNING id INTO v_order_2_session_1_id;

    INSERT INTO order_items (restaurant_id, order_id, menu_item_id, quantity, unit_price, subtotal, notes)
    VALUES
      (v_restaurant_id, v_order_2_session_1_id, v_item_carbonara_id, 1, 16.99, 16.99, 'Extra crispy pancetta');

    -- Session 2: Closed/Paid session at Table 2
    INSERT INTO sessions (restaurant_id, table_id, session_pin, session_token, status, num_diners, started_at, expires_at, closed_at)
    VALUES (v_restaurant_id, v_table_2_id, '654321', 'token-table2-paid', 'paid', 1, CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP - INTERVAL '1 hour', CURRENT_TIMESTAMP - INTERVAL '1.5 hours')
    ON CONFLICT (session_token) DO UPDATE SET status = 'paid', closed_at = CURRENT_TIMESTAMP - INTERVAL '1.5 hours'
    RETURNING id INTO v_session_2_id;

    -- User for Session 2
    INSERT INTO users (restaurant_id, session_id, name, diner_sequence)
    VALUES (v_restaurant_id, v_session_2_id, 'Charlie', 1)
    ON CONFLICT (session_id, diner_sequence) DO NOTHING;

    SELECT id INTO v_user_1_session_2_id FROM users WHERE session_id = v_session_2_id AND diner_sequence = 1;

    -- Order 1 for Session 2 (by Charlie)
    INSERT INTO orders (restaurant_id, session_id, user_id, order_number, status, subtotal, tax, total, special_instructions)
    VALUES (v_restaurant_id, v_session_2_id, v_user_1_session_2_id, 1, 'served', 34.99, 2.80, 37.79, 'Medium rare steak')
    ON CONFLICT (session_id, order_number) DO UPDATE SET status = 'served'
    RETURNING id INTO v_order_1_session_2_id;

    INSERT INTO order_items (restaurant_id, order_id, menu_item_id, quantity, unit_price, subtotal, notes)
    VALUES
      (v_restaurant_id, v_order_1_session_2_id, v_item_ribeye_id, 1, 34.99, 34.99, NULL);

    -- Payment for Session 2
    INSERT INTO payments (restaurant_id, session_id, amount, payment_method, payment_gateway_id, status, receipt_id)
    VALUES (v_restaurant_id, v_session_2_id, 37.79, 'credit_card', 'pg_txn_12345', 'completed', 'receipt_67890')
    ON CONFLICT (session_id, payment_gateway_id) DO NOTHING; -- Assuming payment_gateway_id is unique per session for simplicity

END $$;
