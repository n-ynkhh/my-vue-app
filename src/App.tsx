import { useRecoilState } from 'recoil';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import './App.css'
import DataDisplayPage from './pages/DataDisplayPage/DataDisplayPage';
import LoginPage from './pages/LoginPage';
import MenuPage from './pages/MenuPage';
import Header from './components/Header';
import Footer from './components/Footer';
import { loginState } from './state/loginState';

const App: React.FC = () => {
  const [loginInfo, setLoginInfo] = useRecoilState(loginState);

  const handleLogout = () => {
    setLoginInfo({ isLoggedIn: false, userId: null });
  };

  const handleLogin = (id: string) => {
    setLoginInfo({ isLoggedIn: true, userId: id });
  };

  return (
    <Router>
      <Header onLogout={handleLogout} isLoggedIn={loginInfo.isLoggedIn} />
        <div className="main-content">
          <Routes>
          <Route path="/login" element={!loginInfo.isLoggedIn ? <LoginPage onLogin={handleLogin} /> : <Navigate to="/" />} />
          <Route path="/" element={loginInfo.isLoggedIn ? <MenuPage /> : <Navigate to="/login" />} />
          <Route path="/:numKey" element={loginInfo.isLoggedIn ? <DataDisplayPage /> : <Navigate to="/login" />} />
          </Routes>
          </div>
        <Footer />
    </Router>
  );
};

export default App;
