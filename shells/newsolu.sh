#!/bin/bash

# GitLabのプライベートトークン設定
PRIVATE_TOKEN="YOUR_PRIVATE_TOKEN"
PER_PAGE=100

# 引数から年月を取得、未指定の場合は前月を設定
if [ -z "$1" ]; then
    YEAR_MONTH=$(date -d "1 month ago" '+%Y-%m')
else
    YEAR_MONTH=$1
fi

# JSTで指定された年月の初日の0時をUTCに変換（9時間引く）
START_DATE=$(date -u -d "$YEAR_MONTH-01 00:00:00 JST -9 hours" '+%Y-%m-%dT%H:%M:%SZ')

# JSTで指定された年月の最終日の23時59分をUTCに変換（9時間引く）
END_DATE=$(date -u -d "$YEAR_MONTH-01 00:00:00 JST +1 month -1 second -9 hours" '+%Y-%m-%dT%H:%M:%SZ')

process_merge_requests() {
    project_id=$1
    merge_requests_combined="[]"
    # 作成日に基づくマージリクエストの取得
    page=1
    while : ; do
        merge_requests=$(curl -s "https://gitlab.com/api/v4/projects/$project_id/merge_requests?private_token=$PRIVATE_TOKEN&created_after=$START_DATE&created_before=$END_DATE&per_page=$PER_PAGE&page=$page")
        if [ -z "$merge_requests" ] || [ "$merge_requests" = "[]" ]; then
            break
        fi
        merge_requests_combined=$(echo "$merge_requests_combined $merge_requests" | jq -s 'add | unique_by(.id)')
        ((page++))
    done

    # 更新日に基づくマージリクエストの取得
    page=1
    while : ; do
        merge_requests=$(curl -s "https://gitlab.com/api/v4/projects/$project_id/merge_requests?private_token=$PRIVATE_TOKEN&updated_after=$START_DATE&updated_before=$END_DATE&per_page=$PER_PAGE&page=$page")
        if [ -z "$merge_requests" ] || [ "$merge_requests" = "[]" ]; then
            break
        fi
        merge_requests_combined=$(echo "$merge_requests_combined $merge_requests" | jq -s 'add | unique_by(.id)')
        ((page++))
    done

    # ここで統合されたマージリクエストリストを使用
}

# すべてのプロジェクトIDを取得し、それぞれのプロジェクトのマージリクエストを処理
project_page=1
while : ; do
    projects=$(curl -s "https://gitlab.com/api/v4/projects?private_token=$PRIVATE_TOKEN&per_page=$PER_PAGE&page=$project_page" | jq -c '.[] | select(.forked_from_project == null)')

    if [ -z "$projects" ]; then
        break
    fi

    echo "$projects" | while IFS= read -r project; do
        project_id=$(echo "$project" | jq -r '.id')
        process_merge_requests "$project_id"
    done

    ((project_page++))
    next_page=$(curl -sI "https://gitlab.com/api/v4/projects/$project_id/merge_requests?private_token=$PRIVATE_TOKEN&per_page=$PER_PAGE&page=$((project_page+1))" | grep -Fi x-next-page | awk '{print $2}' | tr -d '\r')
    if [ -z "$next_page" ] || [ "$next_page" = "0" ]; then
        break
    fi
done
