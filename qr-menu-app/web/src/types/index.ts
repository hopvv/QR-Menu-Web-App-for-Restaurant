export interface MenuItem {
  id: string;
  name: string;
  description: string;
  price: number;
  categoryId: string;
  is_available: boolean;
  photo_url: string;
}

export interface Category {
  id: string;
  name: string;
}

export interface CartItem {
  menuItem: MenuItem;
  quantity: number;
}

export interface User {
  id: string;
  username: string;
  role: "admin" | "customer";
}
