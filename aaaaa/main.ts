import React, { useState, useMemo, useEffect } from 'react';
import { useTable, usePagination } from '@tanstack/react-table';

const MyTable = ({ columns, data, searchText, highlightIndex }) => {
  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    page,
    prepareRow,
    nextPage,
    previousPage,
    canNextPage,
    canPreviousPage,
    pageOptions,
    gotoPage,
    state: { pageIndex, pageSize },
  } = useTable(
    {
      columns,
      data,
      initialState: { pageIndex: 0 }, // 初期ページ設定
    },
    usePagination
  );

  // データフィルタリングとハイライト
  const filteredData = useMemo(() => {
    if (!searchText) return data;
    return data.filter(row => 
      row.some(cell => String(cell).toLowerCase().includes(searchText.toLowerCase()))
    );
  }, [data, searchText]);

  // ハイライトされた行が現在のページに存在するか確認し、存在しない場合ページを変更
  useEffect(() => {
    if (highlightIndex >= 0) {
      const totalDataIndex = filteredData.findIndex((_, index) => index === highlightIndex);
      const targetPage = Math.floor(totalDataIndex / pageSize);
      if (targetPage !== pageIndex) {
        gotoPage(targetPage);
      }
    }
  }, [highlightIndex, filteredData, pageSize, pageIndex, gotoPage]);

  return (
    <>
      <table {...getTableProps()}>
        <thead>
          {headerGroups.map(headerGroup => (
            <tr {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map(column => (
                <th {...column.getHeaderProps()}>{column.render('Header')}</th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody {...getTableBodyProps()}>
          {page.map((row, i) => {
            prepareRow(row);
            return (
              <tr
                {...row.getRowProps()}
                style={{
                  backgroundColor: highlightIndex === row.index ? 'yellow' : 'white',
                }}
              >
                {row.cells.map(cell => (
                  <td {...cell.getCellProps()}>{cell.render('Cell')}</td>
                ))}
              </tr>
            );
          })}
        </tbody>
      </table>
      <div>
        <button onClick={() => previousPage()} disabled={!canPreviousPage}>
          前のページ
        </button>
        <button onClick={() => nextPage()} disabled={!canNextPage}>
          次のページ
        </button>
        <span>
          ページ{' '}
          <strong>
            {pageIndex + 1} / {pageOptions.length}
          </strong>
        </span>
      </div>
    </>
  );
};

const MyComponent = ({ columns, data }) => {
  const [searchText, setSearchText] = useState('');
  const [highlightIndex, setHighlightIndex] = useState(-1);

  const handleSearchChange = (event) => {
    setSearchText(event.target.value);
    setHighlightIndex(-1);
  };

  const filteredData = useMemo(() => {
    if (!searchText) return data;
    return data.filter(row => 
      row.some(cell => String(cell).toLowerCase().includes(searchText.toLowerCase()))
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
      const prevIndex = (prevIndex - 1 + matchCount) % matchCount;
      return prevIndex;
    });
  };

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
      <MyTable
        columns={columns}
        data={filteredData}
        searchText={searchText}
        highlightIndex={highlightIndex}
      />
    </div>
  );
};
