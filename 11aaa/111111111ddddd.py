import snowflake.connector
import pandas as pd

# Snowflakeに接続
conn = snowflake.connector.connect(
    user='your_user',
    password='your_password',
    account='your_account',
    warehouse='your_warehouse',
    database='your_database',
    schema='your_schema'
)

# ステージング領域の作成
create_stage_query = "CREATE OR REPLACE STAGE my_stage;"
conn.cursor().execute(create_stage_query)

# CSVファイルのPUT（アップロード）
put_query = "PUT file://path/to/your/local_file.csv @my_stage"
conn.cursor().execute(put_query)

# 一時テーブルの作成
create_temp_table_query = """
CREATE OR REPLACE TEMPORARY TABLE temp_table LIKE target_table;
"""
conn.cursor().execute(create_temp_table_query)

# ステージング領域から一時テーブルへのコピー
copy_into_query = """
COPY INTO temp_table
FROM @my_stage/local_file.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"');
"""
conn.cursor().execute(copy_into_query)

# テーブルのマージ（アップデート）
merge_query = """
MERGE INTO target_table t
USING temp_table s
ON t.id = s.id
WHEN MATCHED THEN
  UPDATE SET t.column1 = s.column1, t.column2 = s.column2, ...
WHEN NOT MATCHED THEN
  INSERT (id, column1, column2, ...)
  VALUES (s.id, s.column1, s.column2, ...);
"""
conn.cursor().execute(merge_query)

# クリーンアップ
drop_temp_table_query = "DROP TABLE temp_table;"
conn.cursor().execute(drop_temp_table_query)

drop_stage_query = "DROP STAGE my_stage;"
conn.cursor().execute(drop_stage_query)

# コネクションを閉じる
conn.close()
