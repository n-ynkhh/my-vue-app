#!/bin/bash

# GitLabのプライベートトークン設定
PRIVATE_TOKEN="YOUR_PRIVATE_TOKEN"
PER_PAGE=100
SQL_FILE="merge_requests.sql"

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

# SQLファイルの初期化
echo "-- Merge requests data into Snowflake" > $SQL_FILE

process_merge_requests() {
    project_id=$1
    project_name=$2
    namespace_path=$3
    merge_requests_combined="[]"
    
    # 作成日または更新日に基づくマージリクエストの取得と統合
    for date_type in "created" "updated"; do
        mr_page=1
        while : ; do
            merge_requests=$(curl -s "https://gitlab.com/api/v4/projects/$project_id/merge_requests?private_token=$PRIVATE_TOKEN&${date_type}_after=$START_DATE&${date_type}_before=$END_DATE&per_page=$PER_PAGE&page=$mr_page")
            if [ -z "$merge_requests" ] || [ "$merge_requests" = "[]" ]; then
                break
            fi
            merge_requests_combined=$(echo "$merge_requests_combined $merge_requests" | jq -s 'add | unique_by(.id)')
            ((mr_page++))
        done
    done

    # 統合されたマージリクエストリストからSQLコマンドを生成してファイルに出力
    echo "$merge_requests_combined" | jq -r --arg project_name "$project_name" --arg namespace_path "$namespace_path" \
        '.[] | "INSERT INTO your_merge_requests_table (mr_id, group_name, project_name, title, created_at, state, author, merged_at, source_branch, mr_url) VALUES (\(.id), \($namespace_path), \($project_name), \(.title | gsub("'"'"'; "'"'"''"'"'")), \(.created_at), \(.state), \(.author.username), \(.merged_at // "NULL"), \(.source_branch), \(.web_url)) ON CONFLICT (mr_id) DO UPDATE SET title = EXCLUDED.title, created_at = EXCLUDED.created_at, state = EXCLUDED.state, author = EXCLUDED.author, merged_at = EXCLUDED.merged_at, source_branch = EXCLUDED.source_branch, mr_url = EXCLUDED.mr_url;"' >> $SQL_FILE
}

# 以降のプロジェクト取得と処理のループは変更なし...
