import { MongoClient } from 'mongodb';

const uri = 'mongodb://localhost:27017';
const client = new MongoClient(uri);

async function seedDatabase() {
    try {
        await client.connect();
        const database = client.db('qr_menu');
        const menuCollection = database.collection('menu');

        const initialMenuItems = [
            { name: 'Margherita Pizza', price: 8.99, category: 'Pizza' },
            { name: 'Caesar Salad', price: 6.99, category: 'Salad' },
            { name: 'Spaghetti Carbonara', price: 10.99, category: 'Pasta' },
            { name: 'Tiramisu', price: 4.99, category: 'Dessert' },
        ];

        const result = await menuCollection.insertMany(initialMenuItems);
        console.log(`${result.insertedCount} menu items were inserted.`);
    } catch (error) {
        console.error('Error seeding database:', error);
    } finally {
        await client.close();
    }
}

seedDatabase();