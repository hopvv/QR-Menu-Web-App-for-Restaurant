import { Pool } from "pg";
import dotenv from "dotenv";

dotenv.config();

// Create a PostgreSQL connection pool
const pool = new Pool({
	user: process.env.DB_USER || "qr_menu_user",
	password: process.env.DB_PASS || "qr_menu_password",
	host: process.env.DB_HOST || "localhost",
	port: parseInt(process.env.DB_PORT || "5432", 10),
	database: process.env.DB_NAME || "qr_menu_db",
	max: parseInt(process.env.DATABASE_POOL_MAX || "20", 10),
	min: parseInt(process.env.DATABASE_POOL_MIN || "5", 10),
});

// Test the database connection
pool.on("connect", () => {
	console.log("PostgreSQL connection pool established");
});

pool.on("error", (err: Error) => {
	console.error("Unexpected error on idle client", err);
});

export const query = (text: string, params?: any[]) => {
	return pool.query(text, params);
};

export default pool;
