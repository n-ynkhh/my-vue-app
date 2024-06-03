import React, { useMemo, useState } from 'react';
import { useReactTable, getCoreRowModel, ColumnDef } from '@tanstack/react-table';

// 全角と半角文字を処理するためのテキストを正規化する関数
const normalizeText = (text: string) => {
  return text.replace(/[Ａ-Ｚａ-ｚ０-９]/g, (s) => {
    return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
  });
};

type Company = {
  company_name: string;
  // 他のフィールド
};

const TableComponent = ({ data }: { data: Company[] }) => {
  const [filterInput, setFilterInput] = useState('');

  const columns = useMemo<ColumnDef<Company>[]>(() => [
    {
      accessorKey: 'company_name',
      header: 'Company Name',
    },
    // 他のカラム
  ], []);

  const table = useReactTable({
    data,
    columns,
    state: {
      globalFilter: filterInput,
    },
    globalFilterFn: (rows: Row<Company>[], columnIds: string[], filterValue: string) => {
      const normalizedFilterValue = normalizeText(filterValue);
      return rows.filter(row => {
        const cellValue = row.original.company_name;
        const normalizedCellValue = normalizeText(cellValue);
        return normalizedCellValue.includes(normalizedFilterValue);
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
                  {header.isPlaceholder ? null : header.renderHeader()}
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

// カスタムフィルタ関数の型定義
const globalFilterFn = (rows: RowModel<Company>[], columnIds: string[], filterValue: string) => {
  const normalizedFilterValue = normalizeText(filterValue);
  return rows.filter(row => {
    return columnIds.some(columnId => {
      const cellValue = row.original[columnId];
      const normalizedCellValue = normalizeText(String(cellValue));
      return normalizedCellValue.includes(normalizedFilterValue);
    });
  });
};
