#!/bin/bash

# SalesforceのインスタンスURL
INSTANCE_URL="https://your_instance.salesforce.com"

# アクセストークン
ACCESS_TOKEN="your_access_token"

# CSVファイル
CSV_FILE="your_data.csv"

# ジョブの作成
JOB_ID=$(curl -X POST "$INSTANCE_URL/services/async/vXX.0/job" \
  -H "X-SFDC-Session: $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
        "operation":"insert",
        "object":"Account",
        "contentType":"CSV",
        "lineEnding":"LF"
      }' | grep '<id>' | sed 's/<[^>]*>//g')

# CSVファイルのアップロード
curl -X PUT "$INSTANCE_URL/services/async/vXX.0/job/$JOB_ID/batch" \
  -H "X-SFDC-Session: $ACCESS_TOKEN" \
  -H "Content-Type: text/csv" \
  --data-binary @"$CSV_FILE"

# ジョブのクローズ
curl -X POST "$INSTANCE_URL/services/async/vXX.0/job/$JOB_ID" \
  -H "X-SFDC-Session: $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
        "state":"Closed"
      }'
