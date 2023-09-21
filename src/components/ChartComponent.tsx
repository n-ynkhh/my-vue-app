import React from 'react';
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);
import { Bar } from 'react-chartjs-2';
import data from '../data';

type Props = {
  dataKey: string;
  checkedItems: { [key: string]: boolean };
};

const ChartComponent: React.FC<Props> = ({ dataKey, checkedItems }) => {
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

  const chartLabels = Array.from(new Set(filteredData.map(item => String(item[dataKey as keyof typeof item]))));
  const chartDataCounts = chartLabels.map(label =>
    filteredData.filter(item => String(item[dataKey as keyof typeof item]) === label).length
  );
  const chartData = {
    labels: chartLabels,
    datasets: [
      {
        label: 'Number of Records',
        data: chartDataCounts,
        backgroundColor: 'rgba(75,192,192,0.4)',
        borderColor: 'rgba(75,192,192,1)',
        borderWidth: 1,
        hoverBackgroundColor: 'rgba(75,192,192,0.6)',
        hoverBorderColor: 'rgba(75,192,192,1)',
      }
    ]
  };

  return <Bar data={chartData} />;
};

export default ChartComponent;
