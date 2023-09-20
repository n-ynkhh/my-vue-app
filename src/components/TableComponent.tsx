import React from 'react';
import { DataItem } from '../data';

interface TableComponentProps {
  data: DataItem[];
  numKey: 'num1' | 'num2' | 'num3';
}

const TableComponent: React.FC<TableComponentProps> = ({ data, numKey }) => {
  return (
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Industry</th>
          <th>Prefactures</th>
          <th>{numKey}</th>
        </tr>
      </thead>
      <tbody>
        {data.map((item, index) => (
          <tr key={index}>
            <td>{item.name}</td>
            <td>{item.industry}</td>
            <td>{item.prefactures}</td>
            <td>{item[numKey]}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

export default TableComponent;
