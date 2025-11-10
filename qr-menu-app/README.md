# QR Menu Web App for Restaurant

A simple, mobile-friendly QR menu for restaurants. Customers can scan a QR code placed on tables to view the menu directly from their phones without needing to install any app.

## Project Structure

The project is organized into the following main directories:

- **web**: Contains the frontend application built with React.
  - **public**: Static files, including the main HTML file.
  - **src**: Source code for the React application, including components, pages, hooks, and styles.
  
- **server**: Contains the backend application built with Node.js and Express.
  - **src**: Source code for the server, including routes, controllers, services, and database models.
  
- **infra**: Contains Docker configuration files for containerizing the application.
  
- **scripts**: Contains scripts for database seeding and other utilities.

## Setup Instructions

### Prerequisites

- Node.js (version 14 or higher)
 - Node.js (version 24 or higher)
- npm (Node Package Manager)
- Docker (for containerization)

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd qr-menu-app
   ```

2. Install dependencies for both the web and server applications:

   ```bash
   cd web
   npm install
   cd ../server
   npm install
   ```

3. Set up environment variables:

   Copy the `.env.example` file to `.env` and update the values as needed.

4. Run the application:

   You can run the web and server applications separately or use Docker to run them together.

   To run the web application:

   ```bash
   cd web
   npm start
   ```

   To run the server application:

   ```bash
   cd server
    # for development (ts-node)
    npm start

   # for production (run compiled JS after `npm run build`)
   npm run build
   npm run start:prod
   ```

### Using Docker

To run the application using Docker, navigate to the `infra` directory and use the following command:

```bash
docker-compose up
```

## Usage Guidelines

- Customers can access the menu by scanning the QR code displayed on the tables.
- Admins can log in to the admin panel to update menu items, prices, and categories.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or features.

## License

This project is licensed under the MIT License.