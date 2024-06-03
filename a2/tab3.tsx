import React, { useMemo, useState } from 'react';
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  flexRender,
  ColumnDef,
  Row,
} from '@tanstack/react-table';

// 全角と半角を区別しないフィルタリング関数
const filterAlphanumeric = (row: Row<any>, columnId: string, filterValue: string) => {
  const normalizedFilterValue = filterValue.normalize('NFKC').toLowerCase();
  const rowValue = row.getValue(columnId).normalize('NFKC').toLowerCase();
  return rowValue.includes(normalizedFilterValue);
};

const App: React.FC = () => {
  const data = useMemo(
    () => [
      { id: 1, name: 'ＡＢＣ123' },
      { id: 2, name: 'abc123' },
      { id: 3, name: 'ａｂｃ１２３' },
    ],
    []
  );

  const columns = useMemo<ColumnDef<any>[]>(
    () => [
      {
        accessorKey: 'id',
        header: 'ID',
      },
      {
        accessorKey: 'name',
        header: 'Name',
      },
    ],
    []
  );

  const [filterInput, setFilterInput] = useState<string>('');

  const table = useReactTable({
    data,
    columns,
    state: {
      globalFilter: filterInput,
    },
    onGlobalFilterChange: setFilterInput,
    globalFilterFn: filterAlphanumeric,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
  });

  // フィルタリングのハンドラー
  const handleFilterChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFilterInput(e.target.value);
  };

  return (
    <>
      <input
        value={filterInput}
        onChange={handleFilterChange}
        placeholder={'Search by name'}
        style={{ marginBottom: '10px' }}
      />
      <table>
        <thead>
          {table.getHeaderGroups().map(headerGroup => (
            <tr key={headerGroup.id}>
              {headerGroup.headers.map(header => (
                <th key={header.id}>
                  {flexRender(header.column.columnDef.header, header.getContext())}
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
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
};

export default App;


const filterAlphanumeric = (row: Row<any>, columnId: string, filterValue: string) => {
  const normalizedFilterValue = filterValue.normalize('NFKC').toLowerCase();
  const cellValue = row.getValue(columnId);
  if (typeof cellValue !== 'string') {
    return false;
  }
  const rowValue = cellValue.normalize('NFKC').toLowerCase();
  return rowValue.includes(normalizedFilterValue);
};
