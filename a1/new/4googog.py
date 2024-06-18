import pandas as pd
import glob

# ディレクトリ内のすべてのCSVファイルを取得
csv_directory_path = '/mnt/data/csv_files_directory'  # 実際のディレクトリパスに置き換えてください
csv_files = glob.glob(csv_directory_path + "/*.csv")

# 抽出条件リスト
extract_conditions = [
    {'element_id': '特定の文字列1', 'period': '特定の文字列1'},
    {'element_id': '特定の文字列2', 'period': '特定の文字列2'},
    # 追加の条件をここに書く
]

# 抽出したデータを保存するリスト
extracted_data_list = []

# 各CSVファイルからデータを抽出
for csv_file in csv_files:
    df = pd.read_csv(csv_file)
    
    for condition in extract_conditions:
        element_id_condition = condition['element_id']
        period_condition = condition['period']
        extracted_data = df[(df['要素ID'] == element_id_condition) & (df['期間・時点'] == period_condition)]
        extracted_data_list.append(extracted_data)

# すべての抽出データを1つのデータフレームにまとめる
final_extracted_data = pd.concat(extracted_data_list, ignore_index=True)

# 抽出したデータを新しいCSVファイルに保存
output_csv_path = '/mnt/data/final_extracted_data.csv'
final_extracted_data.to_csv(output_csv_path, index=False)

print(f"Extracted data saved to {output_csv_path}")

# Snowflakeへの投入準備（上記の例を参考に）
import snowflake.connector

# Snowflake接続情報
conn = snowflake.connector.connect(
    user='your_username',
    password='your_password',
    account='your_account'
)

# データをSnowflakeに投入する
cursor = conn.cursor()
cursor.execute("USE WAREHOUSE your_warehouse")
cursor.execute("USE DATABASE your_database")
cursor.execute("USE SCHEMA your_schema")

# CSVファイルからデータをロードする
cursor.execute(f"""
    PUT file://{output_csv_path} @%your_table;
    COPY INTO your_table FROM @%your_table FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"');
""")

cursor.close()
conn.close()

print("Data loaded into Snowflake successfully.")
