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
                row_data = [cell.get_text() for cell in row]
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

if __name__ == "__main__":
    main()
