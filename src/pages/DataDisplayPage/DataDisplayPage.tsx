import React from 'react';
import './DataDisplayPage.css';
import ChartComponent from '../../components/ChartComponent';
import TableComponent from '../../components/TableComponent';
import { useRecoilState } from 'recoil';
import { checkboxState, CheckboxStateType } from '../../state/checkboxState';
import data, { DataItem } from '../../data';

interface DataDisplayPageProps {
  numKey: 'num1' | 'num2' | 'num3';
}

const DataDisplayPage: React.FC<DataDisplayPageProps> = ({ numKey }) => {
  const [checkedItems, setCheckedItems] = useRecoilState(checkboxState);

  // Filter data based on checkboxState
  const filteredData: DataItem[] = data.filter(item => {
    return Object.entries(checkedItems).every(([key, value]) => {
      if (value.length === 0) return true;
      return value.includes(item[key as keyof DataItem]);
    });
  });

  return (
    <div>
      <div className="container">
<div className="checkbox-section">
  {['industry', 'prefactures'].map(category => (
    <div key={category}>
      <h3>{category}</h3>
      {Array.from(new Set(data.map(item => String(item[category as keyof DataItem])))).map(value => (
        <div key={value}>
          <input
            type="checkbox"
            checked={checkedItems[category as keyof CheckboxStateType]?.includes(value)}
            onChange={() => {
                const currentItems = checkedItems[category as keyof CheckboxStateType] || [];
                if (currentItems.includes(value)) {
                  setCheckedItems({
                    ...checkedItems,
                    [category]: currentItems.filter(v => v !== value)
                  });
                } else {
                  setCheckedItems({
                    ...checkedItems,
                    [category]: [...currentItems, value]
                  });
                }
              }}
          />
          <label>{value}</label>
        </div>
      ))}
    </div>
  ))}
  </div>


      <div className="chart-section">
        <ChartComponent data={filteredData} numKey={numKey} />
      </div>
      </div>
      <div className="table-section">
        <TableComponent data={filteredData} numKey={numKey} />
      </div>

    </div>
  );
}

export default DataDisplayPage;
