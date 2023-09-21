import React, { useEffect } from 'react';
import { useParams } from 'react-router-dom';
import ChartComponent from '../../components/ChartComponent';
import TableComponent from '../../components/TableComponent';
import pageConfigs from '../../pageConfigs';
import { useRecoilState } from 'recoil';
import { checkboxState, CheckboxItems } from '../../state/checkboxState';
import data from '../../data';

const DataDisplayPage: React.FC = () => {
  const { numKey } = useParams<{ numKey: string }>();
  const [checkedItems, setCheckedItems] = useRecoilState<CheckboxItems>(checkboxState);
  const pageConfig = numKey ? pageConfigs[numKey] : undefined;

  const handleCheckboxChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, checked } = e.target;
    setCheckedItems(prevState => ({
      ...prevState,
      [name]: checked,
    }));
  };

  const renderCheckboxesFor = (key: string) => {
    const uniqueItems: Array<string | number | null> = Array.from(
      new Set(data.map(item => item[key as keyof typeof item]))
    );
    return (
      <div className="checkbox-section">
        <h3>{key}</h3>
        {uniqueItems.map((item, index) => (
          <label key={index} className="checkbox-item">
            <input 
              type="checkbox"
              name={`${key}-${String(item)}`}
              checked={Boolean(checkedItems[`${key}-${String(item)}`])}
              onChange={handleCheckboxChange}
            />
            {item}
          </label>
        ))}
      </div>
    );
  };

  useEffect(() => {
    if (pageConfig) {
      const initialCheckedItems: { [key: string]: boolean } = {};
      Object.keys(pageConfig.conditions).forEach((key) => {
        if (pageConfig.conditions[key]) {
          const uniqueItems = Array.from(new Set(data.map(item => String(item[key as keyof typeof item]))));
          uniqueItems.forEach(item => {
            initialCheckedItems[`${key}-${item}`] = true;
          });
        }
      });
      setCheckedItems(initialCheckedItems);
    }
  }, [pageConfig]);

  if (!pageConfig || !numKey) {
    return <div>No such page</div>;
  }

  return (
    <div className="container">
      <div>
        <div className="checkbox-container">
        {Object.keys(pageConfig.conditions).map(key => pageConfig.conditions[key] && renderCheckboxesFor(key))}
        </div>
        <div className="chart-container">
        {pageConfig.chart && <ChartComponent dataKey={numKey} checkedItems={checkedItems} />}
        </div>
      </div>
      <div className="table-container">
        {pageConfig.table && <TableComponent checkedItems={checkedItems} />}
      </div>
    </div>
  );
};

export default DataDisplayPage;
