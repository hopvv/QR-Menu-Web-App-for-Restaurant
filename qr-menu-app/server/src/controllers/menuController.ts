import { Request, Response } from 'express';
import MenuService from '../services/menuService';

class MenuController {
    async getMenu(req: Request, res: Response) {
        try {
            const menu = await MenuService.getMenu();
            res.status(200).json(menu);
        } catch (error) {
            res.status(500).json({ message: 'Error retrieving menu', error });
        }
    }

    async addMenuItem(req: Request, res: Response) {
        try {
            const newItem = await MenuService.addMenuItem(req.body);
            res.status(201).json(newItem);
        } catch (error) {
            res.status(500).json({ message: 'Error adding menu item', error });
        }
    }

    async updateMenuItem(req: Request, res: Response) {
        try {
            const updatedItem = await MenuService.updateMenuItem(req.params.id, req.body);
            res.status(200).json(updatedItem);
        } catch (error) {
            res.status(500).json({ message: 'Error updating menu item', error });
        }
    }

    async deleteMenuItem(req: Request, res: Response) {
        try {
            await MenuService.deleteMenuItem(req.params.id);
            res.status(204).send();
        } catch (error) {
            res.status(500).json({ message: 'Error deleting menu item', error });
        }
    }
}

export default new MenuController();