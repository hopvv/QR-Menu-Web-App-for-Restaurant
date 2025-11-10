import { Item } from '../models/item';

class MenuService {
    private items: Item[] = [];

    constructor() {
        // Initialize with some default items if needed
        this.items = this.loadItems();
    }

    private loadItems(): Item[] {
        // Logic to load items from the database or a file
        return [];
    }

    public getAllItems(): Item[] {
        return this.items;
    }

    public getItemById(id: string): Item | undefined {
        return this.items.find(item => item.id === id);
    }

    public addItem(newItem: Item): void {
        this.items.push(newItem);
        this.saveItems();
    }

    public updateItem(updatedItem: Item): void {
        const index = this.items.findIndex(item => item.id === updatedItem.id);
        if (index !== -1) {
            this.items[index] = updatedItem;
            this.saveItems();
        }
    }

    public deleteItem(id: string): void {
        this.items = this.items.filter(item => item.id !== id);
        this.saveItems();
    }

    private saveItems(): void {
        // Logic to save items to the database or a file
    }
}

export default new MenuService();