#!/bin/bash

# 設定
ACCESS_TOKEN="your_access_token"
PROJECT_ID="your_project_id"
MR_IID="your_mr_iid"  # Merge Requestの内部ID
GITLAB_URL="https://gitlab.example.com"

# Merge Requestのコメント数を取得
COMMENTS_JSON=$(curl --header "PRIVATE-TOKEN: ${ACCESS_TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/merge_requests/${MR_IID}/notes")
COMMENTS_COUNT=$(echo $COMMENTS_JSON | jq '. | length')

# 結果の表示
echo "Comments Count: $COMMENTS_COUNT"
