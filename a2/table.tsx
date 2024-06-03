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
      { id: 1, value: 'ＡＢＣ123' },
      { id: 2, value: 'abc123' },
      { id: 3, value: 'ａｂｃ１２３' },
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
        accessorKey: 'value',
        header: 'Value',
        filterFn: filterAlphanumeric,
      },
    ],
    []
  );

  const [globalFilter, setGlobalFilter] = useState('');

  const table = useReactTable({
    data,
    columns,
    state: {
      globalFilter,
    },
    onGlobalFilterChange: setGlobalFilter,
    globalFilterFn: filterAlphanumeric,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
  });

  return (
    <>
      <input
        value={globalFilter}
        onChange={(e) => setGlobalFilter(e.target.value)}
        placeholder={'Search by value'}
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
          {table.getRowModel().rows.map(row => {
            return (
              <tr {...row.getRowProps()}>
                {row.getVisibleCells().map(cell => (
                  <td {...cell.getCellProps()}>
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </td>
                ))}
              </tr>
            );
          })}
        </tbody>
      </table>
    </>
  );
};

export default App;
