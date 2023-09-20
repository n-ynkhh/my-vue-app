import React from 'react';
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);
import { Bar } from 'react-chartjs-2';
import { DataItem } from '../data';

interface ChartComponentProps {
  data: DataItem[];
  numKey: 'num1' | 'num2' | 'num3';
}

const ChartComponent: React.FC<ChartComponentProps> = ({ data, numKey }) => {
  const chartData = {
    labels: data.map(item => item.name),
    datasets: [
      {
        label: numKey,
        data: data.map(item => item[numKey]),
        backgroundColor: 'rgba(75, 192, 192, 0.2)',
        borderColor: 'rgba(75, 192, 192, 1)',
        borderWidth: 1
      }
    ]
  };

  const options = {
    scales: {
      y: {
        beginAtZero: true
      }
    }
  };

  return <Bar data={chartData} options={options} />;
}

export default ChartComponent;
