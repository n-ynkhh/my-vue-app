import fitz  # PyMuPDF

def extract_text_and_tables(pdf_path):
    doc = fitz.open(pdf_path)
    full_text = ""
    tables = []
    
    for page_num in range(len(doc)):
        page = doc[page_num]
        text = page.get_text("text")
        full_text += text
        
       # Extract tables using find_tables method
        tables_on_page = page.find_tables()
        for table in tables_on_page:
            table_data = []
            for row in table.rows:
                row_data = []
                for cell in row.cells:
                    if isinstance(cell, tuple):
                        row_data.append(cell[4])  # Cell text is likely in the 5th element
                    else:
                        row_data.append(cell.get_text())
                table_data.append(row_data)
            tables.append(table_data)
    
    return full_text, tables

def replace_tables_in_text(full_text, tables):
    modified_text = full_text
    for table in tables:
        table_str = "\n".join(["\t".join(row) for row in table])
        table_list_str = str(table)
        modified_text = modified_text.replace(table_str, table_list_str)
    return modified_text

def main():
    pdf_path = "path/to/your/pdf_file.pdf"  # PDFファイルのパスを指定
    full_text, tables = extract_text_and_tables(pdf_path)
    
    modified_text = replace_tables_in_text(full_text, tables)
    
    print("Modified Text:")
    print(modified_text)
    print()
    
    for i, table in enumerate(tables):
        print(f"Table {i+1}:")
        for row in table:
            print(row)
        print()



# 2次元リストのサンプル
list_2d = [
    ["Hello", "world", None],
    ["This", "is", "a", "test"],
    [None, "Python", "code"]
]

# 2次元リストを各行でjoinする関数
def join_2d_list_with_newline(list_2d):
    joined_lines = []
    for row in list_2d:
        # NoneTypeを空文字列に置き換える
        cleaned_row = [str(item) if item is not None else '' for item in row]
        # 各行をjoinして1つの文字列にする
        joined_lines.append('\n'.join(cleaned_row))
    # 各行をさらに\nで区切って1つの文字列にする
    return '\n'.join(joined_lines)

# 関数を使用して2次元リストをjoinする
result = join_2d_list_with_newline(list_2d)
print(result)


if __name__ == "__main__":
    main()
