import { useState } from 'react';
import { useRecoilState } from 'recoil';
import { authState } from '../state/authState';

function LoginPage() {
  const [isAuthenticated, setIsAuthenticated] = useRecoilState(authState);
  const [userId, setUserId] = useState('');
  const [password, setPassword] = useState('');

  function handleLogin() {
    // In a real-world scenario, you'd send these details to your backend for verification.
    if (userId && password) { // Simple check: if both fields are filled, grant access.
      setIsAuthenticated(true);
    } else {
      alert('Please enter both user ID and password');
    }
  }

  return (
    <div>
      <h2>Login</h2>
      <div>
        <label>
          User ID:
          <input type="text" value={userId} onChange={e => setUserId(e.target.value)} />
        </label>
      </div>
      <div>
        <label>
          Password:
          <input type="password" value={password} onChange={e => setPassword(e.target.value)} />
        </label>
      </div>
      <div>
        <button onClick={handleLogin}>Login</button>
      </div>
    </div>
  );
}

export default LoginPage;