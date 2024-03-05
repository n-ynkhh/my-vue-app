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

# Salesforceからデータ取得 (2000件以上の対応)
NEXT_RECORDS_URL=''
DATA=''

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
    
    DATA+=$(echo $response | jq '.records[]')
    NEXT_RECORDS_URL=$(echo $response | jq -r '.nextRecordsUrl')
    
    if [ "$NEXT_RECORDS_URL" == "null" ]; then
        break
    fi
done

# データの加工とSQL VALUESの生成
SQL_VALUES=""
# ここでDATAを解析してSQL_VALUESを生成するロジックを実装

# Snowflakeにデータを挿入するためのMERGE SQLクエリの組み立て
MERGE_SQL="MERGE INTO $SNOWFLAKE_TABLE AS t USING (SELECT * FROM (VALUES $SQL_VALUES) AS s ($SNOWFLAKE_COLUMNS)) ON t.sf_id = s.sf_id WHEN MATCHED THEN UPDATE SET t.name = s.name, t.custom_field = s.custom_field WHEN NOT MATCHED THEN INSERT (sf_id, name, custom_field) VALUES (s.sf_id, s.name, s.custom_field);"

# Snowflakeにデータを挿入
snowsql -a $SNOWFLAKE_ACCOUNT -u $SNOWFLAKE_USER -p $SNOWFLAKE_PASSWORD -d $SNOWFLAKE_DATABASE -s $SNOWFLAKE_SCHEMA -w $SNOWFLAKE_WAREHOUSE -q "$MERGE_SQL"
