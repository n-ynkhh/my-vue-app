import os
import snowflake.connector

# Snowflakeへの接続設定
conn = snowflake.connector.connect(
    user='YOUR_USER',
    password='YOUR_PASSWORD',
    account='YOUR_ACCOUNT',
    warehouse='YOUR_WAREHOUSE',
    database='YOUR_DATABASE',
    schema='YOUR_SCHEMA'
)

# 特定ディレクトリのパス
directory_path = '/path/to/your/csv/files'

# ディレクトリ内の全CSVファイルをリストアップ
csv_files = [f for f in os.listdir(directory_path) if f.endswith('.csv')]

# テーブル名の指定
table_name = 'YOUR_TABLE'

# テーブルのデータを削除
truncate_command = f"TRUNCATE TABLE {table_name};"
conn.cursor().execute(truncate_command)

# ステージにアップロードし、テーブルにデータをロード
for csv_file in csv_files:
    file_path = os.path.join(directory_path, csv_file)
    stage_name = '@~'
    
    # PUTコマンドでファイルをステージにアップロード
    put_command = f"PUT file://{file_path} {stage_name} AUTO_COMPRESS=TRUE;"
    conn.cursor().execute(put_command)
    
    # テーブルにコピー
    copy_command = f"COPY INTO {table_name} FROM {stage_name}/{csv_file} FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '\"');"
    conn.cursor().execute(copy_command)

# 接続をクローズ
conn.close()
