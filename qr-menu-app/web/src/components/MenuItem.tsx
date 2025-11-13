import React from "react";

interface MenuItemProps {
  id: string;
  name: string;
  description: string;
  price: number;
  is_available: boolean;
  photo_url?: string;
}

const MenuItem: React.FC<MenuItemProps> = ({ id, name, description, price, photo_url }) => {
  return (
    <div className="menu-item" key={id}>
      {photo_url && <img src={photo_url} alt={name} className="menu-item-image" />}
      <h3 className="menu-item-name">{name}</h3>
      <p className="menu-item-description">{description}</p>
      <p className="menu-item-price">${price.toFixed(2)}</p>
    </div>
  );
};

export default MenuItem;
