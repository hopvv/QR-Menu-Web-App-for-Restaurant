export interface MenuItem {
  id: string;
  name: string;
  description: string;
  price: number;
  categoryId: string;
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
