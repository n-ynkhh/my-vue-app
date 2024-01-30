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

# 指定された年月の初日と最終日を計算
START_DATE=$(date -d "$YEAR_MONTH-01" '+%Y-%m-%d')
END_DATE=$(date -d "$YEAR_MONTH-01 +1 month -1 day" '+%Y-%m-%d')

# SQLコマンドの初期化
SQL_COMMANDS=""

process_merge_requests() {
    project_id=$1
    project_name=$2
    namespace_path=$3
    mr_page=1
    while : ; do
        merge_requests=$(curl -s "https://gitlab.com/api/v4/projects/$project_id/merge_requests?private_token=$PRIVATE_TOKEN&created_after=$START_DATE&created_before=$END_DATE&per_page=$PER_PAGE&page=$mr_page")

        if [ -z "$merge_requests" ] || [ "$merge_requests" = "[]" ]; then
            break
        fi

        # ここでマージリクエストのSQLコマンドを生成
        SQL_COMMANDS+=$(echo "$merge_requests" | jq -r --arg project_name "$project_name" --arg namespace_path "$namespace_path" \
            '.[] | "MERGE INTO your_merge_requests_table USING (SELECT '\''\(.id)'\'' AS mr_id, '\''\($namespace_path)'\'' AS group_name, '\''\($project_name)'\'' AS project_name, '\''\(.title)'\'' AS title, '\''\(.created_at)'\'' AS created_at, '\''\(.state)'\'' AS state, '\''\(.author.username)'\'' AS author, '\''\(.merged_at // "NULL")'\'' AS merged_at, '\''\(.source_branch)'\'' AS source_branch, '\''\(.web_url)'\'' AS mr_url) AS src ON your_merge_requests_table.mr_id = src.mr_id AND your_merge_requests_table.group_name = src.group_name AND your_merge_requests_table.project_name = src.project_name WHEN MATCHED THEN UPDATE SET title = src.title, created_at = src.created_at, state = src.state, author = src.author, merged_at = src.merged_at, source_branch = src.source_branch, mr_url = src.mr_url WHEN NOT MATCHED THEN INSERT (mr_id, group_name, project_name, title, created_at, state, author, merged_at, source_branch, mr_url) VALUES (src.mr_id, src.group_name, src.project_name, src.title, src.created_at, src.state, src.author, src.merged_at, src.source_branch, src.mr_url);"')

        ((mr_page++))
    done
}

# すべてのプロジェクトIDを取得し、それぞれのプロジェクトのマージリクエストを取得
project_page=1
while : ; do
    projects=$(curl -s "https://gitlab.com/api/v4/projects?private_token=$PRIVATE_TOKEN&per_page=$PER_PAGE&page=$project_page" | jq -c '.[] | select(.forked_from_project == null)')

    if [ -z "$projects" ]; then
        break
    fi

    echo "$projects" | while IFS= read -r project; do
        project_id=$(echo "$project" | jq -r '.id')
        project_name=$(echo "$project" | jq -r '.name')
        namespace_path=$(echo "$project" | jq -r '.namespace.full_path')
        process_merge_requests "$project_id" "$project_name" "$namespace_path"
    done

    ((project_page++))
    next_page=$(curl -sI "https://gitlab.com/api/v4/projects?private_token=$PRIVATE_TOKEN&per_page=$PER_PAGE&page=$((project_page+1))" | grep -Fi x-next-page | awk '{print $2}' | tr -d '\r')
    if [ -z "$next_page" ] || [ "$next_page" = "0" ]; then
        break
    fi
done

# SnowSQLでSQLコマンドを実行
# 注意: このコマンドを実行する前に、YOUR_USERNAME、YOUR_PASSWORD、YOUR_ACCOUNT等を適切な値に置き換えてください。
echo "$SQL_COMMANDS" | snowsql --username YOUR_USERNAME --password YOUR_PASSWORD --account YOUR_ACCOUNT -q
