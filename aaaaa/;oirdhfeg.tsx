import React, { useState, useMemo, useEffect } from 'react';
import {
  useReactTable,
  getCoreRowModel,
  getPaginationRowModel,
  ColumnDef,
} from '@tanstack/react-table';

const MyComponent = ({ columns, data }: { columns: ColumnDef<any, any>[]; data: any[] }) => {
  const [searchText, setSearchText] = useState('');
  const [highlightIndex, setHighlightIndex] = useState(-1);
  const [pageIndex, setPageIndex] = useState(0);
  const pageSize = 10; // ページサイズを設定

  const handleSearchChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setSearchText(event.target.value);
    setHighlightIndex(-1);
  };

  const filteredData = useMemo(() => {
    if (!searchText) return data;
    return data.filter(row =>
      Object.values(row).some(cell => String(cell).toLowerCase().includes(searchText.toLowerCase()))
    );
  }, [data, searchText]);

  const matchCount = filteredData.length;

  const handleNextHighlight = () => {
    setHighlightIndex(prevIndex => {
      const nextIndex = (prevIndex + 1) % matchCount;
      return nextIndex;
    });
  };

  const handlePreviousHighlight = () => {
    setHighlightIndex(prevIndex => {
      const newIndex = (prevIndex - 1 + matchCount) % matchCount;
      return newIndex;
    });
  };

  const table = useReactTable({
    data: filteredData,
    columns,
    state: {
      pagination: {
        pageIndex,
        pageSize,
      },
    },
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    onPaginationChange: (updater) => {
      const newPageIndex = typeof updater === 'function' ? updater({ pageIndex, pageSize }).pageIndex : updater.pageIndex;
      setPageIndex(newPageIndex);
    },
  });

  // ハイライトされた行が現在のページに存在するか確認し、存在しない場合ページを変更
  useEffect(() => {
    if (highlightIndex >= 0) {
      const totalDataIndex = highlightIndex;
      const targetPage = Math.floor(totalDataIndex / pageSize);
      if (targetPage !== pageIndex) {
        table.setPageIndex(targetPage);
      }
    }
  }, [highlightIndex, filteredData, pageSize, pageIndex, table]);

  return (
    <div>
      <input
        type="text"
        value={searchText}
        onChange={handleSearchChange}
        placeholder="検索..."
      />
      <span>{matchCount}件の該当結果</span>
      <button onClick={handlePreviousHighlight}>←</button>
      <button onClick={handleNextHighlight}>→</button>
      <table>
        <thead>
          {table.getHeaderGroups().map(headerGroup => (
            <tr key={headerGroup.id}>
              {headerGroup.headers.map(header => (
                <th key={header.id}>{header.render('Header')}</th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map(row => (
            <tr
              key={row.id}
              style={{
                backgroundColor: highlightIndex === row.index ? 'yellow' : 'white',
              }}
            >
              {row.getVisibleCells().map(cell => (
                <td key={cell.id}>{cell.render('Cell')}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
      <div>
        <button onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
          前のページ
        </button>
        <button onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>
          次のページ
        </button>
        <span>
          ページ{' '}
          <strong>
            {table.getState().pagination.pageIndex + 1} / {table.getPageCount()}
          </strong>
        </span>
      </div>
    </div>
  );
};

export default MyComponent;
