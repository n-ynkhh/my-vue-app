import React, { useState } from 'react';

type LoginPageProps = {
  onLogin: (id: string) => void;
};

const LoginPage: React.FC<LoginPageProps> = ({ onLogin }) => {
  const [id, setId] = useState('');
  const [password, setPassword] = useState('');

  const handleLoginClick = () => {
    onLogin(id);
  };

  return (
    <div>
      <h2>Login Page</h2>
      <div>
        <label>ID: </label>
        <input type="text" value={id} onChange={(e) => setId(e.target.value)} />
      </div>
      <div>
        <label>Password: </label>
        <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
      </div>
      <button onClick={handleLoginClick}>Login</button>
    </div>
  );
};

export default LoginPage;
