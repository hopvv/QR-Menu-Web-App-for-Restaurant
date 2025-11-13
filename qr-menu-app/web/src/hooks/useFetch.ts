import { useState, useEffect } from "react";
import axios from "axios";

const API_BASE_URL =
	import.meta.env.VITE_API_URL || "http://localhost:5000/api";

const useFetch = (url: string) => {
	const [data, setData] = useState<any>(null);
	const [loading, setLoading] = useState<boolean>(true);
	const [error, setError] = useState<string | null>(null);

	useEffect(() => {
		const fetchData = async () => {
			try {
				const response = await fetch(url);
				if (!response.ok) {
					throw new Error("Network response was not ok");
				}
				const result = await response.json();
				setData(result);
			} catch (err: any) {
				setError(err.message);
			} finally {
				setLoading(false);
			}
		};

		fetchData();
	}, [url]);

	return { data, loading, error };
};

export const fetchMenuItems = async (restaurantId = 1) => {
	try {
		const response = await axios.get(
			`${API_BASE_URL}/menu?restaurantId=${restaurantId}`
		);
		return response.data;
	} catch (error: any) {
		throw new Error(
			error.response?.data?.message || "Failed to fetch menu items"
		);
	}
};

export const updateMenuItem = async (
	itemId: string | number,
	updatedData: any
) => {
	try {
		const response = await axios.put(
			`${API_BASE_URL}/admin/items/${itemId}`,
			updatedData
		);
		return response.data;
	} catch (error: any) {
		throw new Error(
			error.response?.data?.message || "Failed to update menu item"
		);
	}
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
		throw new Error(
			error.response?.data?.message || "Failed to delete menu item"
		);
	}
};

export default useFetch;
