import React from 'react';
import data from '../data';

type Props = {
  checkedItems: { [key: string]: boolean };
};

const TableComponent: React.FC<Props> = ({ checkedItems }) => {
  const filteredData = data.filter(item => {
    const keysGroupedByCategory: { [key: string]: string[] } = {};

    // Group checked items by their category
    Object.keys(checkedItems).forEach(key => {
      const [itemKey, itemValue] = key.split('-');
      if (!keysGroupedByCategory[itemKey]) keysGroupedByCategory[itemKey] = [];
      if (checkedItems[key]) keysGroupedByCategory[itemKey].push(itemValue);
    });

    return Object.keys(keysGroupedByCategory).every(itemKey =>
      keysGroupedByCategory[itemKey].some(
        itemValue => String(item[itemKey as keyof typeof item]) === itemValue
      )
    );
  });

  return (
    <table>
      <thead>
        <tr>
          {Object.keys(data[0]).map((key, index) => (
            <th key={index}>{key}</th>
          ))}
        </tr>
      </thead>
      <tbody>
        {filteredData.map((row, index) => (
          <tr key={index}>
            {Object.values(row).map((value, i) => (
              <td key={i}>{value}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default TableComponent;
