import './App.css';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { useRecoilValue } from 'recoil';
import { authState } from './state/authState';
import Header from './components/Header';
import Footer from './components/Footer';
import DataDisplayPage from './pages/DataDisplayPage/DataDisplayPage';
import LoginPage from './pages/LoginPage';
import MenuPage from './pages/MenuPage';

function App() {
  const isAuthenticated = useRecoilValue(authState);

  return (
    <Router>
          <div className="app-container">
      <Header />
      <div className="main-content">
      <main>
        <Routes>
          {isAuthenticated ? (
            <>
              <Route path="/menu" element={<MenuPage />} />
              <Route path="/num1" element={<DataDisplayPage numKey="num1" />} />
              <Route path="/num2" element={<DataDisplayPage numKey="num2" />} />
              <Route path="/num3" element={<DataDisplayPage numKey="num3" />} />
            </>
          ) : (
            <>
              <Route path="/login" element={<LoginPage />} />
              <Route path="*" element={<LoginPage />} />
            </>
          )}
        </Routes>
      </main>
      </div>
      <Footer />
      </div>
    </Router>
  );
}

export default App;
