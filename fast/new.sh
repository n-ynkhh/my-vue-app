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

# Salesforceからのアクセストークン取得
get_access_token() {
    response=$(curl -s -X POST $SFDC_AUTH_URL \
        -d "grant_type=password" \
        -d "client_id=$CLIENT_ID" \
        -d "client_secret=$CLIENT_SECRET" \
        -d "username=$USERNAME" \
        -d "password=$PASSWORD")

    echo $(echo $response | jq -r '.access_token')
}

# Salesforceからデータ取得
query_salesforce() {
    local soql_query="$1"
    local access_token="$2"
    local instance_url="$3"
    
    curl -s -H "Authorization: Bearer $access_token" \
         -H "Content-Type: application/json" \
         "$instance_url/services/data/vXX.0/query/?q=$(echo -n $soql_query | jq -sRr @uri)"
}

# Snowflakeにデータ挿入
insert_snowflake() {
    local merge_sql="$1"
    snowsql -a $SNOWFLAKE_ACCOUNT -u $SNOWFLAKE_USER -p $SNOWFLAKE_PASSWORD -d $SNOWFLAKE_DATABASE -s $SNOWFLAKE_SCHEMA -w $SNOWFLAKE_WAREHOUSE -q "$merge_sql"
}

# メイン処理
main() {
    # Salesforceのアクセストークン取得
    ACCESS_TOKEN=$(get_access_token)

    # SOQLクエリの定義
    SOQL_QUERY="SELECT $SFDC_COLUMNS FROM ObjectA WHERE ..."

    # Salesforceからデータ取得
    SFDC_DATA=$(query_salesforce "$SOQL_QUERY" "$ACCESS_TOKEN" "$SFDC_INSTANCE_URL")

    # データの加工とSQL VALUESの生成
    SQL_VALUES=""
    # ここでSFDC_DATAを解析してSQL_VALUESを生成するロジックを実装

    # Snowflakeにデータを挿入するためのMERGE SQLクエリの組み立て
    MERGE_SQL="MERGE INTO $SNOWFLAKE_TABLE AS t USING (SELECT * FROM (VALUES $SQL_VALUES) AS s ($SNOWFLAKE_COLUMNS)) ON t.sf_id = s.sf_id WHEN MATCHED THEN UPDATE SET t.name = s.name, t.custom_field = s.custom_field WHEN NOT MATCHED THEN INSERT (sf_id, name, custom_field) VALUES (s.sf_id, s.name, s.custom_field);"

    # Snowflakeにデータを挿入
    insert_snowflake "$MERGE_SQL"
}

# スクリプトの実行
main




SOQL_QUERY="SELECT Id, Name, (SELECT Id, Name FROM ObjectB_Relationship_Name__r WHERE Contract_Status__c = '契約中') FROM ObjectA WHERE CreatedDate = YESTERDAY OR LastModifiedDate = YESTERDAY"
