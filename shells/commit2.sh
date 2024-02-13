#!/bin/bash

# Personal Access Tokenを設定
TOKEN="your_personal_access_token_here"
# GitLabインスタンスのURL
GITLAB_URL="https://gitlab.example.com"
# 出力ファイル
OUTPUT_FILE="insert_all_commits.sql"

# 引数から年月を取得、または前月を計算
if [ -n "$1" ]; then
    YEAR_MONTH=$1
else
    YEAR_MONTH=$(date --date='1 month ago' '+%Y-%m')
fi

# 指定された月の最初と最後の日時を計算
START_DATE="${YEAR_MONTH}-01T00:00:00Z"
END_DATE=$(date -d "$START_DATE +1 month -1 second" '+%Y-%m-%dT%H:%M:%SZ')

# 出力ファイルの初期化
echo "-- SQL statements to insert all commit details into the database in a single query for commits between $START_DATE and $END_DATE" > "$OUTPUT_FILE"
echo "INSERT INTO commits (group_name, project_name, author_name, commit_date, commit_hash, commit_message, added_lines, deleted_lines, is_merge_commit) VALUES" >> "$OUTPUT_FILE"

# すべてのプロジェクトを取得し、各プロジェクトのコミットを処理
FIRST_RECORD=true
curl --header "Private-Token: $TOKEN" "$GITLAB_URL/api/v4/projects?per_page=100" | jq -c '.[]' | while read i; do
    PROJECT_ID=$(echo $i | jq -r '.id')
    PROJECT_NAME=$(echo $i | jq -r '.name')
    GROUP_NAME=$(echo $i | jq -r '.namespace.name')
    DEFAULT_BRANCH=$(echo $i | jq -r '.default_branch')

    # 指定された期間のコミットを取得
    curl --header "Private-Token: $TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/repository/commits?ref_name=$DEFAULT_BRANCH&since=$START_DATE&until=$END_DATE&per_page=100" | jq -c '.[]' | while read j; do
        COMMIT_HASH=$(echo $j | jq -r '.id')
        AUTHOR_NAME=$(echo $j | jq -r '.author_name')
        COMMIT_DATE=$(echo $j | jq -r '.committed_date')
        COMMIT_MESSAGE=$(echo $j | jq -r '.title' | sed -e 's/\"/\\\"/g')
        IS_MERGE_COMMIT=$(echo $j | jq -r '.parent_ids | length > 1')

        # コミットのdiffを取得
        DIFFS=$(curl --silent --header "Private-Token: $TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/repository/commits/$COMMIT_HASH/diff" | jq -r '.[] | .diff')

        # 追加および削除された行数を計算
        ADDED_LINES=$(echo "$DIFFS" | grep -E '^\+' | grep -Ev '^\+\+\+' | wc -l)
        DELETED_LINES=$(echo "$DIFFS" | grep -E '^-' | grep -Ev '^---' | wc -l)
        
        # 最初のレコードでなければカンマを追加
        if [ "$FIRST_RECORD" = true ]; then
            FIRST_RECORD=false
        else
            echo "," >> "$OUTPUT_FILE"
        fi

        # INSERT文の値部分を出力
        echo -n "(\"$GROUP_NAME\", \"$PROJECT_NAME\", \"$AUTHOR_NAME\", \"$COMMIT_DATE\", \"$COMMIT_HASH\", \"$COMMIT_MESSAGE\", $ADDED_LINES, $DELETED_LINES, $IS_MERGE_COMMIT)" >> "$OUTPUT_FILE"
    done
done

# 最後にセミコロンを追加してクエリを終了
echo ";" >> "$OUTPUT_FILE"
