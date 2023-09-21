import React from 'react';

type HeaderProps = {
  onLogout: () => void;
  isLoggedIn: boolean;
};

const Header: React.FC<HeaderProps> = ({ onLogout, isLoggedIn }) => (
  <div className="header">
    <h1>サイト名</h1>
    {isLoggedIn && <button className="logout-button" onClick={onLogout}>Logout</button>}
  </div>
);

export default Header;