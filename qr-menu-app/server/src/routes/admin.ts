import { Router } from 'express';
import { getItems, addItem, updateItem, deleteItem } from '../controllers/adminController';

const router = Router();

// Route to get all menu items
router.get('/items', getItems);

// Route to add a new menu item
router.post('/items', addItem);

// Route to update an existing menu item
router.put('/items/:id', updateItem);

// Route to delete a menu item
router.delete('/items/:id', deleteItem);

export default router;