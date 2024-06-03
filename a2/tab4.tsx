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
  const cellValue = row.getValue(columnId);
  if (typeof cellValue !== 'string') {
    return false;
  }
  const rowValue = cellValue.normalize('NFKC').toLowerCase();
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

  const globalFilterFn = useMemo(() => {
    return (rows: Row<any>[], columnIds: string[], filterValue: string) => {
      return rows.filter(row => filterAlphanumeric(row, 'name', filterValue));
    };
  }, []);

  const table = useReactTable({
    data,
    columns,
    state: {
      globalFilter: filterInput,
    },
    onGlobalFilterChange: setFilterInput,
    globalFilterFn: globalFilterFn as unknown as TableOptions<any>['globalFilterFn'],
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
  });

  return (
    <>
      <input
        value={filterInput}
        onChange={(e) => setFilterInput(e.target.value)}
        placeholder={'Search by name'}
        style={{ marginBottom: '10px' }}
      />
      <table {...table.getTableProps()}>
        <thead>
          {table.getHeaderGroups().map(headerGroup => (
            <tr key={headerGroup.id} {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map(header => (
                <th key={header.id} {...header.getHeaderProps()}>
                  {flexRender(header.column.columnDef.header, header.getContext())}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody {...table.getTableBodyProps()}>
          {table.getRowModel().rows.map(row => (
            <tr key={row.id} {...row.getRowProps()}>
              {row.getVisibleCells().map(cell => (
                <td key={cell.id} {...cell.getCellProps()}>
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
