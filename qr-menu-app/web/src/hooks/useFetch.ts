import { useState, useEffect } from "react";
import axios from "axios";

const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:5001/api";

export const useFetch = (endpoint: string) => {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`);
        if (!response.ok) throw new Error("Failed to fetch");
        const result = await response.json();
        setData(result);
      } catch (err: Error | unknown) {
        setError(err instanceof Error ? err.message : "Unknown error");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [endpoint]);

  return { data, loading, error };
};

// Fetch menu items
export const fetchMenuItems = async () => {
  const response = await fetch(`${API_BASE_URL}/menu`);
  if (!response.ok) throw new Error("Failed to fetch menu items");
  return response.json();
};

// Update menu item
export const updateMenuItem = async (itemId: string, updatedData: Record<string, any>) => {
  const response = await fetch(`${API_BASE_URL}/admin/items/${itemId}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(updatedData),
  });
  if (!response.ok) throw new Error("Failed to update menu item");
  return response.json();
};

export const addMenuItem = async (itemData: any) => {
  try {
    const response = await axios.post(`${API_BASE_URL}/admin/items`, itemData);
    return response.data;
  } catch (error: any) {
    throw new Error(error.response?.data?.message || "Failed to add menu item");
  }
};

export const deleteMenuItem = async (itemId: string | number) => {
  try {
    await axios.delete(`${API_BASE_URL}/admin/items/${itemId}`);
  } catch (error: any) {
    throw new Error(error.response?.data?.message || "Failed to delete menu item");
  }
};

export default useFetch;
