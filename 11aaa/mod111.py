import snowflake.connector
import requests
import random
import os
import fitz  # PyMuPDF
import pandas as pd

# Snowflake接続情報
conn_params = {
    'user': 'your_username',
    'password': 'your_password',
    'account': 'your_account',
    'warehouse': 'your_warehouse',
    'database': 'your_database',
    'schema': 'your_schema'
}

# テーブル名とカラム名
table_name = 'your_table'
url_column = 'your_url_column'
name_column = 'name'
edinet_code_column = 'edinet_code'

# PDFの保存先ディレクトリ
save_dir = 'pdf_downloads'
os.makedirs(save_dir, exist_ok=True)

def fetch_random_records():
    # Snowflakeに接続
    conn = snowflake.connector.connect(**conn_params)
    try:
        # レコード数を取得
        query_count = f'SELECT COUNT(*) FROM {table_name}'
        cursor = conn.cursor()
        cursor.execute(query_count)
        row_count = cursor.fetchone()[0]

        # ランダムなインデックスを生成
        random_indices = random.sample(range(row_count), 100)

        # ランダムなレコードを取得
        records = []
        for idx in random_indices:
            query = f'SELECT {url_column}, {name_column}, {edinet_code_column} FROM {table_name} LIMIT 1 OFFSET {idx}'
            cursor.execute(query)
            records.append(cursor.fetchone())

        return records
    finally:
        conn.close()

def download_pdf(url, index):
    try:
        response = requests.get(url)
        response.raise_for_status()
        pdf_path = os.path.join(save_dir, f'document_{index+1}.pdf')
        with open(pdf_path, 'wb') as file:
            file.write(response.content)
        return pdf_path
    except requests.exceptions.RequestException as e:
        print(f'Failed to download {url}: {e}')
        return None

def extract_text_from_pdf(pdf_path):
    try:
        document = fitz.open(pdf_path)
        text = ''
        for page_num in range(len(document)):
            page = document.load_page(page_num)
            text += page.get_text()
        document.close()
        return text
    except Exception as e:
        print(f'Failed to extract text from {pdf_path}: {e}')
        return ''

def main():
    records = fetch_random_records()
    results = []

    for i, record in enumerate(records):
        url, name, edinet_code = record
        pdf_path = download_pdf(url, i)
        if pdf_path:
            text = extract_text_from_pdf(pdf_path)
            text_length = len(text)
            results.append({
                'URL': url,
                'Name': name,
                'EDINET Code': edinet_code,
                'PDF Text Length': text_length
            })

    # 結果をCSVに保存
    df = pd.DataFrame(results)
    df.to_csv('pdf_text_lengths.csv', index=False)

if __name__ == '__main__':
    main()
