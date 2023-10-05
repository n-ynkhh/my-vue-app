import React from 'react';
import CustomTable from './CustomTable';

const SomePage: React.FC = () => {
  const columns = [
    {
      Header: '名前',
      accessor: 'name',
    },
    {
      Header: '年齢',
      accessor: 'age',
    },
  ];

  const data = [
    {
      name: '太郎',
      age: 25,
    },
    {
      name: '花子',
      age: 30,
    },
  ];

  return (
    <div>
      <CustomTable columns={columns} data={data} />
    </div>
  );
}

export default SomePage;
