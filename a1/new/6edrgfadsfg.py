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

# 連結用の抽出条件リスト
concat_extract_conditions = [
    {'element_id': '連結特定の文字列1', 'period': '連結特定の文字列1'},
    {'element_id': '連結特定の文字列2', 'period': '連結特定の文字列2'},
    # 追加の条件をここに書く
]

# 抽出したデータを保存するリスト
final_data_list = []

# 各CSVファイルからデータを抽出して1行にまとめる
for csv_file in csv_files:
    print(f"Processing file: {csv_file}")
    df = pd.read_csv(csv_file)
    
    # 単体抽出
    extracted_row_single = []
    for condition in extract_conditions:
        element_id_condition = condition['element_id']
        period_condition = condition['period']
        extracted_data = df[(df['要素ID'] == element_id_condition) & (df['期間・時点'] == period_condition)]
        
        # 抽出したデータの値をリストに追加
        extracted_row_single.append(extracted_data['値'].values[0] if not extracted_data.empty else None)
    
    # ファイル名も含める
    extracted_row_single.insert(0, csv_file.split('/')[-1])
    final_data_list.append(extracted_row_single)

    # 連結の有無をチェックして連結抽出
    if '連結の有無' in df.columns and df['連結の有無'].iloc[0] == True:
        extracted_row_concat = []
        for condition in concat_extract_conditions:
            element_id_condition = condition['element_id']
            period_condition = condition['period']
            extracted_data = df[(df['要素ID'] == element_id_condition) & (df['期間・時点'] == period_condition)]
            
            # 抽出したデータの値をリストに追加
            extracted_row_concat.append(extracted_data['値'].values[0] if not extracted_data.empty else None)
        
        # ファイル名も含める
        extracted_row_concat.insert(0, csv_file.split('/')[-1] + '_concat')
        final_data_list.append(extracted_row_concat)

# 抽出したデータをデータフレームに変換
column_names = ['ファイル名'] + [f"条件_{i+1}" for i in range(len(extract_conditions))]
final_extracted_data = pd.DataFrame(final_data_list, columns=column_names)

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
