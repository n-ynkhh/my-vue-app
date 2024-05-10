#!/bin/bash

# JSONデータの例（複数レコードを想定）
DATA='[{"a":"valueA1","b":"valueB1","c":"文字列1　文字列2　文字列3"},{"a":"valueA2","b":"valueB2","c":"文字列A　文字列B"}]'

# SQLファイルのパス
SQL_FILE="insert_data.sql"

# SQLファイルが既に存在する場合は削除
rm -f $SQL_FILE

# Snowflakeへの接続情報設定（適宜書き換えてください）
SNOWFLAKE_DATABASE="your_database"
SNOWFLAKE_SCHEMA="your_schema"
SNOWFLAKE_TABLE="your_table"

# JSON配列から各オブジェクトを処理
echo $DATA | jq -c '.[]' | while read i; do
  # 各キーを変数に割り当て
  a_val=$(echo $i | jq -r '.a')
  b_val=$(echo $i | jq -r '.b')
  c_values=$(echo $i | jq -r '.c' | tr '　' '\n')

  # cの値を分割して処理
  while read -r c_val; do
    if [ -n "$c_val" ]; then
      # SQL文をファイルに追記
      echo "MERGE INTO $SNOWFLAKE_TABLE AS target USING (SELECT '$a_val' AS a, '$b_val' AS b, '$c_val' AS c) AS source ON target.b = source.b AND target.c = source.c WHEN NOT MATCHED THEN INSERT (a, b, c) VALUES (source.a, source.b, source.c);" >> $SQL_FILE
    fi
  done <<< "$c_values"
done

# SQLファイルをSnowSQLを使って実行
snowsql -d $SNOWFLAKE_DATABASE -s $SNOWFLAKE_SCHEMA -f $SQL_FILE

echo "処理が完了しました。"


#!/bin/bash

# ファイル名が格納された変数
file1="path/to/your/file1.txt"
file2="path/to/your/file2.txt"
file3="path/to/your/file3.txt"

# ファイル名の変数を配列に格納
files=("$file1" "$file2" "$file3")

# 配列の各要素に対してループ
for file in "${files[@]}"
do
  # ファイルが存在し、かつファイルサイズが0の場合に削除
  if [ -f "$file" ] && [ ! -s "$file" ]; then
    rm "$file"
    echo "Deleted: $file"
  fi
done
