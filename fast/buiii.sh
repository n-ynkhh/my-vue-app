#!/bin/bash

# Salesforceのフィールド名とSnowflakeのカラム名 (例: "Id,Name,CustomField__c")
sfdc_columns="Id,Name,CustomField__c"
snowflake_columns="sf_id,name,custom_field"

# カンマ区切りの文字列をBash配列に変換
IFS=',' read -r -a sfdc_array <<< "$sfdc_columns"
IFS=',' read -r -a snowflake_array <<< "$snowflake_columns"

# Salesforceから取得したデータ (JSON形式)
DATA='[{"Id":"001...","Name":"Sample Name 1","CustomField__c":"Custom Value 1"},{"Id":"002...","Name":"Sample Name 2","CustomField__c":"Custom Value 2"}]'

# SQL_VALUESの初期化
SQL_VALUES=""

# DATA変数をループし、各レコードから必要な情報を抽出
echo $DATA | jq -c '.[]' | while read -r record; do
    # 一時的なVALUES文字列
    temp_values=""

    # Salesforceフィールド配列をループし、各フィールド値を抽出
    for i in "${!sfdc_array[@]}"; do
        field="${sfdc_array[$i]}"
        value=$(echo $record | jq -r --arg field "$field" '.[$field]')
        # temp_valuesにフィールド値を追加
        if [ -z "$temp_values" ]; then
            temp_values="'$value'"
        else
            temp_values="$temp_values, '$value'"
        fi
    done

    # SQL_VALUESにこのレコードのVALUES部分を追加
    if [ -z "$SQL_VALUES" ]; then
        SQL_VALUES="($temp_values)"
    else
        SQL_VALUES="$SQL_VALUES, ($temp_values)"
    fi
done

# Snowflakeへのデータ挿入用のMERGE SQLクエリの組み立て
MERGE_SQL="MERGE INTO your_table AS t USING (SELECT * FROM (VALUES $SQL_VALUES) AS s (${snowflake_columns})) ON t.${snowflake_array[0]} = s.${snowflake_array[0]} WHEN MATCHED THEN UPDATE SET "
for i in "${!snowflake_array[@]}"; do
    if [ "$i" -ne 0 ]; then # 最初のカラムはON句で使用しているためスキップ
        MERGE_SQL+="t.${snowflake_array[$i]} = s.${snowflake_array[$i]}"
        if [ "$i" -lt $((${#snowflake_array[@]} - 1)) ]; then
            MERGE_SQL+=", "
        fi
    fi
done
MERGE_SQL+=" WHEN NOT MATCHED THEN INSERT (${snowflake_columns}) VALUES (s.${snowflake_columns//,/, s.});"

# 結果のMERGE SQLクエリの出力 (デバッグ用)
echo "$MERGE_SQL"
