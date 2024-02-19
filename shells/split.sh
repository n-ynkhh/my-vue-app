#!/bin/bash

# 設定
PRIVATE_TOKEN="YOUR_PRIVATE_TOKEN"
PER_PAGE=100
SQL_FILE="merge_requests.sql"

# 引数から年月を取得、未指定の場合は前月を設定
if [ -z "$1" ]; then
    YEAR_MONTH=$(date -d "1 month ago" '+%Y-%m')
else
    YEAR_MONTH=$1
fi

# 指定年月の初日と最終日を設定（UTC）
START_DATE=$(date -u -d "$YEAR_MONTH-01" '+%Y-%m-%dT%H:%M:%SZ')
END_DATE=$(date -u -d "$YEAR_MONTH-01 next month -1 second" '+%Y-%m-%dT%H:%M:%SZ')

# SQLファイルを初期化
echo "-- Merge requests data into Snowflake" > $SQL_FILE

# マージリクエストを処理する関数
process_merge_requests() {
    project_id=$1
    project_name=$2
    namespace_path=$3

    # 指定年月に作成されたMRのINSERT文を生成
    echo "INSERT INTO your_merge_requests_table (mr_id, group_name, project_name, title, created_at, state, author, merged_at, source_branch, mr_url) VALUES" >> $SQL_FILE
    page=1
    while : ; do
        merge_requests=$(curl -s "https://gitlab.com/api/v4/projects/$project_id/merge_requests?private_token=$PRIVATE_TOKEN&created_after=$START_DATE&created_before=$END_DATE&per_page=$PER_PAGE&page=$page")
        last_page=$(echo "$merge_requests" | jq -r '. | length')

        echo "$merge_requests" | jq -r --arg project_name "$project_name" --arg namespace_path "$namespace_path" \
        '.[] | "(\(.id), '\''\($namespace_path)'\'', '\''\($project_name)'\'', '\''\(.title | gsub("'"'"'; "'"'"''"'"'"))'\'', '\''\(.created_at)'\'', '\''\(.state)'\'', '\''\(.author.username)'\'', '\''\(.merged_at // "NULL")'\'', '\''\(.source_branch)'\'', '\''\(.web_url)'\''),"' >> $SQL_FILE

        [ "$last_page" -lt "$PER_PAGE" ] && break
        ((page++))
    done

    # 最後のカンマを削除し、セミコロンを追加
    sed -i '$ s/,$/;/' $SQL_FILE

    # 指定年月に更新されたがそれ以前に作成されたMRのMERGEクエリを生成
    # この部分に関しては、必要に応じて具体的なMERGEクエリを記述してください
}

# プロジェクトごとにマージリクエストを処理
project_page=1
while : ; do
    projects=$(curl -s "https://gitlab.com/api/v4/projects?private_token=$PRIVATE_TOKEN&per_page=$PER_PAGE&page=$project_page" | jq -c '.[] | select(.forked_from_project == null)')
    [ -z "$projects" ] && break

    echo "$projects" | while IFS= read -r project; do
        project_id=$(echo "$project" | jq -r '.id')
        project_name=$(echo "$project" | jq -r '.name')
        namespace_path=$(echo "$project" | jq -r '.namespace.full_path')
        process_merge_requests "$project_id" "$project_name" "$namespace_path"
    done

    ((project_page++))
    next_page=$(curl -sI "https://gitlab.com/api/v4/projects/$project_id/merge_requests?private_token=$PRIVATE_TOKEN&per_page=$PER_PAGE&page=$((project_page+1))" | grep -Fi x-next-page | awk '{print $2}' | tr -d '\r')
    [ -z "$next_page" ] || [ "$next_page" = "0" ] && break
done

# SnowSQLでSQLコマンドを実行
# snowsql --username YOUR_USERNAME --password YOUR_PASSWORD --account YOUR_ACCOUNT -f $SQL_FILE
