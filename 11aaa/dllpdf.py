import snowflake.connector
import requests
import random
import os

# Snowflake接続情報
conn_params = {
    'user': 'your_username',
    'password': 'your_password',
    'account': 'your_account',
    'warehouse': 'your_warehouse',
    'database': 'your_database',
    'schema': 'your_schema'
}

# テーブル名とURLカラム名
table_name = 'your_table'
url_column = 'your_url_column'

# PDFの保存先ディレクトリ
save_dir = 'pdf_downloads'
os.makedirs(save_dir, exist_ok=True)

def fetch_random_urls():
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

        # ランダムなURLを取得
        urls = []
        for idx in random_indices:
            query = f'SELECT {url_column} FROM {table_name} LIMIT 1 OFFSET {idx}'
            cursor.execute(query)
            urls.append(cursor.fetchone()[0])

        return urls
    finally:
        conn.close()

def download_pdfs(urls):
    for i, url in enumerate(urls):
        try:
            response = requests.get(url)
            response.raise_for_status()
            pdf_path = os.path.join(save_dir, f'document_{i+1}.pdf')
            with open(pdf_path, 'wb') as file:
                file.write(response.content)
            print(f'Successfully downloaded: {pdf_path}')
        except requests.exceptions.RequestException as e:
            print(f'Failed to download {url}: {e}')

if __name__ == '__main__':
    urls = fetch_random_urls()
    download_pdfs(urls)
