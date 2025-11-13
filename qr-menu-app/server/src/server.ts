import express, { Express } from "express";
import bodyParser from "body-parser";
import cors from "cors";
import dotenv from "dotenv";
import pool from "./db";
import menuRoutes from "./routes/menu";
import adminRoutes from "./routes/admin";

dotenv.config();

const app: Express = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use("/api/menu", menuRoutes);
app.use("/api/admin", adminRoutes);

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, () => {
  console.log(`✓ Server is running on http://localhost:${PORT}`);
  console.log(`✓ Environment: ${process.env.NODE_ENV || "development"}`);
});
