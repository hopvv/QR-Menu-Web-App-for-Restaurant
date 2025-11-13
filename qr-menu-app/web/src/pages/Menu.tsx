import React, { useEffect, useState } from "react";
import MenuItem from "../components/MenuItem";
import CategoryList from "../components/CategoryList";
import useFetch from "../hooks/useFetch";

const Menu = () => {
  const { data: menuItems, loading, error } = useFetch("/api/menu");
  const [categories, setCategories] = useState([]);

  useEffect(() => {
    if (menuItems) {
      const uniqueCategories = [...new Set(menuItems.map((item) => item.category))];
      setCategories(uniqueCategories);
    }
  }, [menuItems]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error loading menu.</div>;

  return (
    <div className="menu-container">
      <h1>Restaurant Menu</h1>
      <CategoryList categories={categories} />
      <div className="menu-items">
        {menuItems.map((item) => (
          <MenuItem key={item.id} item={item} />
        ))}
      </div>
    </div>
  );
};

export default Menu;
