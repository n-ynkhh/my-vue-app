import pandas as pd
from snowflake.connector import connect

# CSVファイルを読み込み、最初の行をスキップ
file_path = '/mnt/data/EdinetcodeDlInfo.csv'
df = pd.read_csv(file_path, skiprows=1, encoding='shift_jis')

# 決算日の列をTIMESTAMP_NTZ(9)形式に変換
df['決算日'] = pd.to_datetime(df['決算日'], errors='coerce')

# Snowflakeの接続情報を設定
snowflake_user = 'YOUR_SNOWFLAKE_USER'
snowflake_password = 'YOUR_SNOWFLAKE_PASSWORD'
snowflake_account = 'YOUR_SNOWFLAKE_ACCOUNT'
snowflake_warehouse = 'YOUR_WAREHOUSE'
snowflake_database = 'YOUR_DATABASE'
snowflake_schema = 'YOUR_SCHEMA'
snowflake_table = 'YOUR_TABLE'

# Snowflakeに接続
conn = connect(
    user=snowflake_user,
    password=snowflake_password,
    account=snowflake_account,
    warehouse=snowflake_warehouse,
    database=snowflake_database,
    schema=snowflake_schema
)

# テーブルをTRUNCATE
truncate_query = f"TRUNCATE TABLE {snowflake_table}"
conn.cursor().execute(truncate_query)

# データを一時ファイルに保存（UTF-8エンコーディング）
temp_csv_path = '/mnt/data/EdinetcodeDlInfo_temp.csv'
df.to_csv(temp_csv_path, index=False, encoding='utf-8')

# Snowflakeステージにデータをアップロードしてテーブルにロード
put_query = f"PUT file://{temp_csv_path} @%{snowflake_table}"
copy_query = f"""
COPY INTO {snowflake_table}
FROM @%{snowflake_table}/EdinetcodeDlInfo_temp.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
"""

conn.cursor().execute(put_query)
conn.cursor().execute(copy_query)

# 接続を閉じる
conn.close()

print("データのロードが完了しました。")


copy_query = f"""
COPY INTO {snowflake_table}
FROM @%{snowflake_table}/EdinetcodeDlInfo_temp.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 0)
COLUMN_NAMES = (column1, column2, ..., 決算日);
"""
