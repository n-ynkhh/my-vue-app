#!/bin/bash

# Salesforce 認証情報とエンドポイント
SFDC_INSTANCE_URL="https://your_instance.salesforce.com"
SFDC_AUTH_URL="https://login.salesforce.com/services/oauth2/token"
CLIENT_ID="your_client_id"
CLIENT_SECRET="your_client_secret"
USERNAME="your_username"
PASSWORD="your_password_with_security_token"

# Snowflake 認証情報
SNOWFLAKE_ACCOUNT="your_account"
SNOWFLAKE_USER="your_user"
SNOWFLAKE_PASSWORD="your_password"
SNOWFLAKE_DATABASE="your_database"
SNOWFLAKE_SCHEMA="your_schema"
SNOWFLAKE_WAREHOUSE="your_warehouse"
SNOWFLAKE_TABLE="your_table"

# Salesforceの項目名とSnowflakeのカラム名
SFDC_COLUMNS="Id,Name,CustomField__c"
SNOWFLAKE_COLUMNS="sf_id,name,custom_field"

# Salesforceのアクセストークン取得
response=$(curl -s -X POST $SFDC_AUTH_URL \
    -d "grant_type=password" \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET" \
    -d "username=$USERNAME" \
    -d "password=$PASSWORD")

ACCESS_TOKEN=$(echo $response | jq -r '.access_token')

# SOQLクエリの調整
if [ "$1" == "all" ]; then
    SOQL_QUERY="SELECT $SFDC_COLUMNS FROM ObjectA WHERE ..."
else
    SOQL_QUERY="SELECT $SFDC_COLUMNS FROM ObjectA WHERE (CreatedDate = YESTERDAY OR LastModifiedDate = YESTERDAY) AND ..."
fi

# SQLファイル名の定義
FILE_NAME="merge_data.sql"

# Salesforceからデータ取得 (2000件以上の対応)
NEXT_RECORDS_URL=''

while true; do
    if [ -z "$NEXT_RECORDS_URL" ]; then
        response=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
             -H "Content-Type: application/json" \
             "$SFDC_INSTANCE_URL/services/data/vXX.0/query/?q=$(echo -n $SOQL_QUERY | jq -sRr @uri)")
    else
        response=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
             -H "Content-Type: application/json" \
             "$SFDC_INSTANCE_URL$NEXT_RECORDS_URL")
    fi
    
    DATA=$(echo $response | jq '.records')

    # SQLファイルの生成
    > "$FILE_NAME"  # ファイルを初期化
    VALUES=""
    echo $DATA | jq -c '.[]' | while read -r record; do
        id=$(echo $record | jq -r '.Id')
        name=$(echo $record | jq -r '.Name')
        custom_field=$(echo $record | jq -r '.CustomField__c')
        VALUES="$VALUES, ('$id', '$name', '$custom_field')"
    done
    VALUES=$(echo $VALUES | cut -c 3-)  # 先頭の", "を削除
    echo "MERGE INTO $SNOWFLAKE_TABLE AS t USING (SELECT * FROM (VALUES $VALUES) AS v ($SNOWFLAKE_COLUMNS)) AS s ON t.sf_id = s.sf_id WHEN MATCHED THEN UPDATE SET t.name = s.name, t.custom_field = s.custom_field WHEN NOT MATCHED THEN INSERT ($SNOWFLAKE_COLUMNS) VALUES (s.sf_id, s.name, s.custom_field);" >> "$FILE_NAME"

    # Snowflakeにデータを挿入
    snowsql -a $SNOWFLAKE_ACCOUNT -u $SNOWFLAKE_USER -p $SNOWFLAKE_PASSWORD -f "$FILE_NAME"

    # 次のレコードのURLを取得
    NEXT_RECORDS_URL=$(echo $response | jq -r '.nextRecordsUrl')

    # 次のレコードがなければ終了
    if [ "$NEXT_RECORDS_URL" == "null" ]; then
        break
    fi
done

# 処理が完了したらSQLファイルを削除
rm "$FILE_NAME"



    # JSON配列をイテレートしてVALUESを組み立てる
    RECORD_COUNT=$(echo $DATA | jq '. | length')
    for (( i = 0; i < RECORD_COUNT; i++ )); do
        RECORD=$(echo $DATA | jq ".[$i] | @sh")
        ID=$(echo $RECORD | cut -d' ' -f2)
        NAME=$(echo $RECORD | cut -d' ' -f3)
        CUSTOM_FIELD=$(echo $RECORD | cut -d' ' -f4)
        VALUES="$VALUES, ($ID, $NAME, $CUSTOM_FIELD)"
    done
