import { query } from "../db";

export class MenuService {
	async getItems() {
		const result = await query("SELECT * FROM menu_items");
		return result.rows;
	}

	async getItemById(id: number) {
		const result = await query("SELECT * FROM menu_items WHERE id = $1", [id]);
		return result.rows[0];
	}

	async addItem(
		restaurantId: number,
		categoryId: number,
		name: string,
		description: string,
		price: number,
		photoUrl?: string
	) {
		const result = await query(
			"INSERT INTO menu_items (restaurant_id, category_id, name, description, price, photo_url, is_available) VALUES ($1, $2, $3, $4, $5, $6, true) RETURNING *",
			[restaurantId, categoryId, name, description, price, photoUrl]
		);
		return result.rows[0];
	}

	async updateItem(id: number, updateData: any) {
		const { name, description, price, isAvailable, photoUrl } = updateData;
		const result = await query(
			"UPDATE menu_items SET name = COALESCE($1, name), description = COALESCE($2, description), price = COALESCE($3, price), is_available = COALESCE($4, is_available), photo_url = COALESCE($5, photo_url), updated_at = CURRENT_TIMESTAMP WHERE id = $6 RETURNING *",
			[name, description, price, isAvailable, photoUrl, id]
		);
		return result.rows[0];
	}

	async deleteItem(id: number) {
		await query("DELETE FROM menu_items WHERE id = $1", [id]);
	}
}
