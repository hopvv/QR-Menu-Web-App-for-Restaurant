import { Request, Response } from 'express';
import { MenuService } from '../services/menuService';

class AdminController {
    private menuService: MenuService;

    constructor() {
        this.menuService = new MenuService();
    }

    public async addItem(req: Request, res: Response): Promise<void> {
        try {
            const newItem = await this.menuService.addItem(req.body);
            res.status(201).json(newItem);
        } catch (error) {
            res.status(500).json({ message: 'Error adding item', error });
        }
    }

    public async updateItem(req: Request, res: Response): Promise<void> {
        try {
            const updatedItem = await this.menuService.updateItem(req.params.id, req.body);
            res.status(200).json(updatedItem);
        } catch (error) {
            res.status(500).json({ message: 'Error updating item', error });
        }
    }

    public async deleteItem(req: Request, res: Response): Promise<void> {
        try {
            await this.menuService.deleteItem(req.params.id);
            res.status(204).send();
        } catch (error) {
            res.status(500).json({ message: 'Error deleting item', error });
        }
    }

    public async getItems(req: Request, res: Response): Promise<void> {
        try {
            const items = await this.menuService.getItems();
            res.status(200).json(items);
        } catch (error) {
            res.status(500).json({ message: 'Error fetching items', error });
        }
    }
}

export default new AdminController();