import React, { useEffect, useState } from "react";
import { fetchMenuItems, updateMenuItem } from "../hooks/useFetch";

const Admin: React.FC = () => {
  const [menuItems, setMenuItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const loadMenuItems = async () => {
      try {
        const items = await fetchMenuItems();
        setMenuItems(items);
      } catch (err) {
        setError("Failed to load menu items");
      } finally {
        setLoading(false);
      }
    };

    loadMenuItems();
  }, []);

  const handleUpdate = async (itemId: string, updatedData: any) => {
    try {
      await updateMenuItem(itemId, updatedData);
      setMenuItems((prevItems) =>
        prevItems.map((item) => (item.id === itemId ? { ...item, ...updatedData } : item))
      );
    } catch (err) {
      setError("Failed to update menu item");
    }
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>{error}</div>;

  return (
    <div>
      <h1>Admin Panel</h1>
      <ul>
        {menuItems.map((item) => (
          <li key={item.id}>
            <span>
              {item.name} - ${item.price}
            </span>
            <button onClick={() => handleUpdate(item.id, { price: item.price + 1 })}>
              Increase Price
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default Admin;
