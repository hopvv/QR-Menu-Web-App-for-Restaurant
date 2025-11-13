-- Insert demo restaurant
INSERT INTO restaurants (name, slug, api_key, is_active, timezone) 
VALUES ('Demo Restaurant', 'demo-restaurant', 'sk_demo_test123', true, 'UTC')
ON CONFLICT (slug) DO NOTHING;

-- Insert sample tables (using fixed restaurant ID 1)
INSERT INTO tables (restaurant_id, table_number, capacity, is_active, location) 
VALUES 
  (1, '1', 4, true, 'Window Seat'),
  (1, '2', 2, true, 'Bar'),
  (1, '3', 6, true, 'Patio'),
  (1, '4', 4, true, 'Corner')
ON CONFLICT DO NOTHING;

-- Insert menu categories
INSERT INTO menu_categories (restaurant_id, name, description, sort_order, is_active)
VALUES
  (1, 'Appetizers', 'Start your meal', 1, true),
  (1, 'Mains', 'Main courses', 2, true),
  (1, 'Desserts', 'Sweet treats', 3, true),
  (1, 'Beverages', 'Drinks', 4, true)
ON CONFLICT DO NOTHING;

-- Insert sample menu items
INSERT INTO menu_items (restaurant_id, category_id, name, description, price, is_available, photo_url, sort_order)
VALUES
  (1, 1, 'Spring Rolls', 'Crispy spring rolls with sweet dipping sauce', 8.99, true, 'https://via.placeholder.com/300x200', 1),
  (1, 1, 'Calamari Fritti', 'Golden fried squid rings', 12.99, true, 'https://via.placeholder.com/300x200', 2),
  (1, 2, 'Grilled Salmon', 'Fresh Atlantic salmon with lemon butter', 24.99, true, 'https://via.placeholder.com/300x200', 1),
  (1, 2, 'Ribeye Steak', 'Premium 14oz ribeye', 34.99, true, 'https://via.placeholder.com/300x200', 2),
  (1, 2, 'Pasta Carbonara', 'Classic Roman pasta with pancetta and cream', 16.99, true, 'https://via.placeholder.com/300x200', 3),
  (1, 3, 'Tiramisu', 'Traditional Italian dessert', 9.99, true, 'https://via.placeholder.com/300x200', 1),
  (1, 3, 'Chocolate Lava Cake', 'Warm chocolate cake with molten center', 8.99, true, 'https://via.placeholder.com/300x200', 2),
  (1, 4, 'Espresso', 'Single or double shot', 3.99, true, 'https://via.placeholder.com/300x200', 1),
  (1, 4, 'Cappuccino', 'Rich and creamy', 5.99, true, 'https://via.placeholder.com/300x200', 2),
  (1, 4, 'Iced Tea', 'Fresh brewed iced tea', 4.99, true, 'https://via.placeholder.com/300x200', 3)
ON CONFLICT DO NOTHING;

-- Add menu item options for sizes
INSERT INTO menu_item_options (restaurant_id, menu_item_id, option_name, option_type)
VALUES
  (1, 3, 'Size', 'single_select'),
  (1, 4, 'Temperature', 'single_select'),
  (1, 9, 'Size', 'single_select')
ON CONFLICT DO NOTHING;

-- Add option values
INSERT INTO menu_item_option_values (restaurant_id, option_id, value, price_modifier, sort_order)
VALUES
  (1, 1, 'Small', 0, 1),
  (1, 1, 'Medium', 2, 2),
  (1, 1, 'Large', 4, 3),
  (1, 2, 'Rare', 0, 1),
  (1, 2, 'Medium', 0, 2),
  (1, 2, 'Well Done', 0, 3),
  (1, 3, 'Small', 0, 1),
  (1, 3, 'Large', 1.50, 2)
ON CONFLICT DO NOTHING;
