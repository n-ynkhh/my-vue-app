import React, { useMemo, useState } from 'react';
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  flexRender,
  ColumnDef,
} from '@tanstack/react-table';

// 全角と半角を区別しないフィルタリング関数
const filterAlphanumeric = (rows, columnIds, filterValue) => {
  const normalizedFilterValue = filterValue
    .normalize('NFKC')
    .toLowerCase();

  return rows.filter(row => {
    return columnIds.some(columnId => {
      const rowValue = row[columnId]
        .normalize('NFKC')
        .toLowerCase();
      return rowValue.includes(normalizedFilterValue);
    });
  });
};

const App = () => {
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
        filterFn: filterAlphanumeric,
      },
    ],
    []
  );

  const [filterInput, setFilterInput] = useState('');

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

  // グローバルフィルタリング関数
  const handleFilterChange = e => {
    const value = e.target.value || '';
    setFilterInput(value);
    table.setGlobalFilter(value);
  };

  return (
    <>
      <input
        value={filterInput}
        onChange={handleFilterChange}
        placeholder={'Search by name'}
        style={{ marginBottom: '10px' }}
      />
      <table {...table.getTableProps()}>
        <thead>
          {table.getHeaderGroups().map(headerGroup => (
            <tr {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map(column => (
                <th {...column.getHeaderProps()}>
                  {flexRender(column.columnDef.header, column.getContext())}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody {...table.getTableBodyProps()}>
          {table.getRowModel().rows.map(row => (
            <tr {...row.getRowProps()}>
              {row.getVisibleCells().map(cell => (
                <td {...cell.getCellProps()}>
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
