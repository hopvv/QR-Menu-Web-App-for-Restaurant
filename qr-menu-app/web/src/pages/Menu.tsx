import React, { useEffect, useMemo, useState } from "react";
import MenuItem from "../components/MenuItem";
import CategoryList from "../components/CategoryList";
import useFetch from "../hooks/useFetch";
import { MenuItem as MenuItemType } from "../types";

const Menu = () => {
  const { data, loading, error } = useFetch("/menu");
  // const [categories, setCategories] = useState([]);

  const menuItems: MenuItemType[] = useMemo(() => {
    return data?.map((item: MenuItemType) => ({ ...item, price: Number(item.price) })) || [];
  }, [data]);

  // useEffect(() => {
  //   if (menuItems) {
  //     const uniqueCategories = [...new Set(menuItems.map((item) => item.category))];
  //     setCategories(uniqueCategories);
  //   }
  // }, [menuItems]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error loading menu.</div>;

  return (
    <div className="menu-container">
      <h1>Restaurant Menu</h1>
      {/* <CategoryList categories={categories} /> */}
      <div className="menu-items">
        {menuItems.map((item) => (
          <MenuItem
            key={item.id}
            id={item.id}
            name={item.name}
            description={item.description}
            price={item.price}
            is_available={item.is_available}
            photo_url={item.photo_url}
          />
        ))}
      </div>
    </div>
  );
};

export default Menu;
