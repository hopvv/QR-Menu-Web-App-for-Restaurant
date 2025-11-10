import { Router } from 'express';
import { getMenuItems, addMenuItem, updateMenuItem, deleteMenuItem } from '../controllers/menuController';

const router = Router();

// Route to get all menu items
router.get('/', getMenuItems);

// Route to add a new menu item
router.post('/', addMenuItem);

// Route to update an existing menu item
router.put('/:id', updateMenuItem);

// Route to delete a menu item
router.delete('/:id', deleteMenuItem);

export default router;