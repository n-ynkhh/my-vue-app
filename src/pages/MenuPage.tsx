import { useNavigate } from 'react-router-dom';
import './MenuPage.css';

function MenuPage() {
  const navigate = useNavigate();

  const handleButtonClick = (path: string) => {
    navigate(path);
  }

  return (
    <div className="menu-container">
      {['/num1', '/num2', '/num3', '/num4', '/num5', '/num6', '/num7', '/num8', '/num9'].map((path, index) => (
        <button key={index} className="menu-button" onClick={() => handleButtonClick(path)}>
          {`Menu ${index + 1}`}
        </button>
      ))}
    </div>
  );
}

export default MenuPage;
