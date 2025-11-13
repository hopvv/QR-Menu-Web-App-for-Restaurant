import { Request, Response } from "express";
import { query } from "../db";

export const getItems = async (req: Request, res: Response) => {
	try {
		const restaurantId = req.query.restaurantId || 1;
		const result = await query(
			"SELECT id, name, description, price, is_available FROM menu_items WHERE restaurant_id = $1",
			[restaurantId]
		);
		res.status(200).json(result.rows);
	} catch (error) {
		res.status(500).json({ message: "Error fetching items", error });
	}
};

export const addItem = async (req: Request, res: Response) => {
	try {
		const { restaurantId, categoryId, name, description, price, photoUrl } =
			req.body;
		const result = await query(
			"INSERT INTO menu_items (restaurant_id, category_id, name, description, price, photo_url, is_available) VALUES ($1, $2, $3, $4, $5, $6, true) RETURNING *",
			[restaurantId, categoryId, name, description, price, photoUrl]
		);
		res.status(201).json(result.rows[0]);
	} catch (error) {
		res.status(500).json({ message: "Error adding item", error });
	}
};

export const updateItem = async (req: Request, res: Response) => {
	try {
		const { id } = req.params;
		const { name, description, price, isAvailable, photoUrl } = req.body;
		const result = await query(
			"UPDATE menu_items SET name = $1, description = $2, price = $3, is_available = $4, photo_url = $5, updated_at = CURRENT_TIMESTAMP WHERE id = $6 RETURNING *",
			[name, description, price, isAvailable, photoUrl, id]
		);
		res.status(200).json(result.rows[0]);
	} catch (error) {
		res.status(500).json({ message: "Error updating item", error });
	}
};

export const deleteItem = async (req: Request, res: Response) => {
	try {
		const { id } = req.params;
		await query("DELETE FROM menu_items WHERE id = $1", [id]);
		res.status(204).send();
	} catch (error) {
		res.status(500).json({ message: "Error deleting item", error });
	}
};
