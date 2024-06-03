import React, { useMemo, useState } from 'react';
import { useReactTable, getCoreRowModel } from '@tanstack/react-table';

// 全角と半角文字を処理するためのテキストを正規化する関数
const normalizeText = (text: string) => {
  return text.replace(/[Ａ-Ｚａ-ｚ０-９]/g, (s) => {
    return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
  });
};

const TableComponent = ({ data, columns }) => {
  const [filterInput, setFilterInput] = useState('');

  const table = useReactTable({
    data,
    columns,
    state: {
      globalFilter: filterInput,
    },
    globalFilterFn: (rows, columnIds, filterValue) => {
      const normalizedFilterValue = normalizeText(filterValue);
      return rows.filter(row => {
        return columnIds.some(columnId => {
          const cellValue = row.getValue(columnId);
          const normalizedCellValue = normalizeText(cellValue);
          return normalizedCellValue.includes(normalizedFilterValue);
        });
      });
    },
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <>
      <input
        value={filterInput}
        onChange={(e) => setFilterInput(e.target.value)}
        placeholder="検索..."
      />
      <table>
        <thead>
          {table.getHeaderGroups().map(headerGroup => (
            <tr key={headerGroup.id}>
              {headerGroup.headers.map(header => (
                <th key={header.id}>
                  {header.isPlaceholder
                    ? null
                    : header.renderHeader()}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map(row => (
            <tr key={row.id}>
              {row.getVisibleCells().map(cell => (
                <td key={cell.id}>
                  {cell.renderCell()}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
};

export default TableComponent;



import React from 'react';
import TableComponent from './TableComponent';

const data = [
  // あなたのデータ
];

const columns = useMemo(() => [
  {
    accessorKey: 'name',
    header: '名前',
  },
  {
    accessorKey: 'age',
    header: '年齢',
  },
  // 他のカラム
], []);

const App = () => {
  return (
    <div>
      <h1>私のテーブル</h1>
      <TableComponent data={data} columns={columns} />
    </div>
  );
};

export default App;
