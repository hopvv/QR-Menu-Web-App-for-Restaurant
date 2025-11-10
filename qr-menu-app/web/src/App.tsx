import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import Menu from './pages/Menu';
import Admin from './pages/Admin';
import './styles/globals.css';

const App: React.FC = () => {
  return (
    <Router>
      <Switch>
        <Route path="/" exact component={Menu} />
        <Route path="/admin" component={Admin} />
      </Switch>
    </Router>
  );
};

export default App;