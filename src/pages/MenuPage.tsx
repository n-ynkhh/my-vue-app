import React from 'react';
import { Link } from 'react-router-dom';
import pageConfigs from '../pageConfigs';

const MenuPage: React.FC = () => {
  return (
    <div>
      <div className="menu-container">
        {Object.keys(pageConfigs).map((numKey) => (
          <div className="menu-button" key={numKey}>
            <Link to={`/${numKey}`}>{numKey}</Link>
          </div>
        ))}
      </div>
    </div>
  );
};

export default MenuPage;
