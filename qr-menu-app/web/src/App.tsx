import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Menu from "./pages/Menu";
import Admin from "./pages/Admin";
import "./styles/globals.css";

const App: React.FC = () => {
	return (
		<Router>
			<Routes>
				<Route path="/" element={<Menu />} />
				<Route path="/admin" element={<Admin />} />
			</Routes>
		</Router>
	);
};

export default App;
