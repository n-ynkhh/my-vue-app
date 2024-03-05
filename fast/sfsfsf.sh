#!/bin/bash

# Salesforceの設定
INSTANCE_URL="https://yourInstance.salesforce.com"
ACCESS_TOKEN="yourAccessToken"
API_VERSION="vXX.0" # SalesforceのAPIバージョン
sfdc_columns="Id,Name,CustomField__c" # Salesforceで取得する項目名
soql_columns=$(echo $sfdc_columns | sed 's/,/, /g') # SOQLクエリ用にフォーマット
SOQL_QUERY="SELECT $soql_columns FROM ObjectA WHERE (CreatedDate = YESTERDAY OR LastModifiedDate = YESTERDAY) AND ObjectB__r.Contract_Status__c = '契約中'"
ENCODED_SOQL_QUERY=$(echo $SOQL_QUERY | jq -sRr @uri)

# Snowflakeの設定
SNOWFLAKE_ACCOUNT='yourAccount'
SNOWFLAKE_USER='yourUser'
SNOWFLAKE_PASSWORD='yourPassword'
SNOWFLAKE_DATABASE='yourDatabase'
SNOWFLAKE_SCHEMA='yourSchema'
SNOWFLAKE_WAREHOUSE='yourWarehouse'
TARGET_TABLE='yourTargetTable'
snowflake_columns="id,name,custom_field" # Snowflakeの対応する項目名

# Salesforceからデータを取得してMERGEクエリのVALUES句を組み立てる関数
function fetch_and_build_values_clause {
    local query_url="$INSTANCE_URL/services/data/$API_VERSION/query?q=$1"
    local response=$(curl -s "$query_url" -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/json")
    local records=$(echo $response | jq -c '.records[]')
    local values_clause=""

    for record in $records; do
        local values_row="("
        for column in $(echo $sfdc_columns | sed "s/,/ /g"); do
            local value=$(echo $record | jq -r --arg COLUMN "$column" '.[$COLUMN]')
            values_row+="'$value',"
        done
        values_row=${values_row%,} # 最後のコンマを削除
        values_row+="),"
        values_clause+=$values_row
    done

    values_clause=${values_clause%,} # 最後のコンマを削除

    # 次のレコードURLをチェック
    local nextRecordsUrl=$(echo $response | jq -r '.nextRecordsUrl')
    if [ "$nextRecordsUrl" != "null" ]; then
        # 次のURLの一部を抽出し、再帰的に関数を呼び出す
        local nextQuery=$(echo $nextRecordsUrl | sed 's/.*query\(.*\)/\1/')
        values_clause+=$(fetch_and_build_values_clause $nextQuery)
    fi

    echo $values_clause
}

# VALUES句を組み立て
VALUES_CLAUSE=$(fetch_and_build_values_clause $ENCODED_SOQL_QUERY)

# MERGEクエリを組み立て
MERGE_QUERY="MERGE INTO $TARGET_TABLE AS t USING (SELECT * FROM (VALUES $VALUES_CLAUSE) AS s($snowflake_columns)) ON t.id = s.id WHEN MATCHED THEN UPDATE SET t.name = s.name, t.custom_field = s.custom_field WHEN NOT MATCHED THEN INSERT ($snowflake_columns) VALUES (s.id, s.name, s.custom_field);"

# SnowSQLを使用してMERGEクエリを実行
echo "$MERGE_QUERY" | snowsql -a $SNOWFLAKE_ACCOUNT -u $SNOWFLAKE_USER -p $SNOWFLAKE_PASSWORD -d $SNOWFLAKE_DATABASE -s $SNOWFLAKE_SCHEMA -w $SNOWFLAKE_WAREHOUSE
