import { useRecoilState } from 'recoil';
import { authState } from '../state/authState';

function Header() {
    const [isAuthenticated, setIsAuthenticated] = useRecoilState(authState);

  const handleLogout = () => {
    setIsAuthenticated(false);
  };

  return (
    <header>
    <h1>My App</h1>
      {isAuthenticated && (
        <button onClick={handleLogout} style={{ position: 'absolute', top: '10px', right: '10px' }}>
          Logout
        </button>
      )}
    </header>
  );
}

export default Header;