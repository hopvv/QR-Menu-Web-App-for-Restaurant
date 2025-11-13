import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
// Allow reading process.env without requiring @types/node in the build container
declare const process: any;

export default defineConfig({
	plugins: [react()],
	server: {
		port: 3000,
		host: "0.0.0.0",
		strictPort: false,
		// Enable polling when running inside Docker on macOS
		watch: {
			usePolling: process.env.CHOKIDAR_USEPOLLING === "true",
			interval: 100,
		},
	},
	build: {
		outDir: "dist",
		sourcemap: false,
	},
});
