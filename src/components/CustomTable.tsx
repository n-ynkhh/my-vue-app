// CustomTable.tsx
import React from 'react';
import { useTable, useSortBy, usePagination } from 'react-table';
import { TableProps } from './CustomTableTypes';

function CustomTable<T extends Record<string, unknown>>({ columns, data }: TableProps<T>) {
const {
  getTableProps,
  getTableBodyProps,
  headerGroups,
  page,  // 注意: 'rows' から 'page' に変更します
  prepareRow,
  canPreviousPage,
  canNextPage,
  pageOptions,
  pageCount,
  gotoPage,
  nextPage,
  previousPage,
  state: { pageIndex, pageSize },
} = useTable(
  {
    columns,
    data,
    initialState: { pageIndex: 0, pageSize: 10 },  // 例: 1ページあたり10行のデータを表示
  },
  useSortBy,
  usePagination
);

  return (
    <table {...getTableProps()}>
      <thead>
{headerGroup.headers.map(column => (
  <th {...column.getHeaderProps(column.getSortByToggleProps())}>
    {column.render('Header')}
    {/* ソートの状態を示すための文字列/要素を追加 */}
    <span>
      {column.isSorted ? (column.isSortedDesc ? ' 🔽' : ' 🔼') : ''}
    </span>
  </th>
))}
      </thead>
      <tbody {...getTableBodyProps()}>
        {rows.map(row => {
          prepareRow(row);
          return (
            <tr {...row.getRowProps()}>
              {row.cells.map(cell => (
                <td {...cell.getCellProps()}>{cell.render('Cell')}</td>
              ))}
            </tr>
          );
        })}
      </tbody>
      <div className="pagination">
  <button onClick={() => gotoPage(0)} disabled={!canPreviousPage}>
    {'<<'}
  </button>{' '}
  <button onClick={() => previousPage()} disabled={!canPreviousPage}>
    {'<'}
  </button>{' '}
  <button onClick={() => nextPage()} disabled={!canNextPage}>
    {'>'}
  </button>{' '}
  <button onClick={() => gotoPage(pageCount - 1)} disabled={!canNextPage}>
    {'>>'}
  </button>{' '}
  <span>
    Page{' '}
    <strong>
      {pageIndex + 1} of {pageOptions.length}
    </strong>{' '}
  </span>
  <span>
    | Go to page:{' '}
    <input
      type="number"
      defaultValue={pageIndex + 1}
      onChange={e => {
        const page = e.target.value ? Number(e.target.value) - 1 : 0;
        gotoPage(page);
      }}
      style={{ width: '50px' }}
    />
  </span>{' '}
</div>
    </table>
  );
}

export default CustomTable;
