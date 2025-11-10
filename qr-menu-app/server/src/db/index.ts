import { Sequelize } from 'sequelize';

// Database configuration
const database = process.env.DB_NAME || 'qr_menu_db';
const username = process.env.DB_USER || 'root';
const password = process.env.DB_PASS || 'password';
const host = process.env.DB_HOST || 'localhost';
const dialect = 'mysql'; // or 'postgres', 'sqlite', etc.

const sequelize = new Sequelize(database, username, password, {
    host,
    dialect,
});

// Test the database connection
sequelize.authenticate()
    .then(() => {
        console.log('Database connection has been established successfully.');
    })
    .catch(err => {
        console.error('Unable to connect to the database:', err);
    });

export default sequelize;