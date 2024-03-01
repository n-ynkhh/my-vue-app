#!/bin/bash

# トークンとGitLabのURLを設定
TOKEN="your_private_token_here"
OUTPUT_FILE="commits.sql"  # 出力ファイル
PROCESSED_COMMITS_FILE="processed_commits.tmp"  # 処理済みコミットを追跡する一時ファイル
MAX_LINES=2000  # 最大行数

# 出力ファイルと処理済みコミット追跡ファイルの初期化
echo "INSERT INTO commits (group_name, project_name, author_name, commit_date, commit_hash, commit_message, added_lines, deleted_lines, is_merge_commit) VALUES" > "$OUTPUT_FILE"
> "$PROCESSED_COMMITS_FILE"

# プロジェクト情報の取得とページネーション
PAGE=1
while :; do
    PROJECTS=$(curl -s "https://gitlab.example.com/api/v4/projects?private_token=$TOKEN&per_page=100&page=$PAGE&simple=true&membership=true")

    if [ -z "$PROJECTS" ] || [ "$PROJECTS" = "[]" ]; then
        break
    fi

    echo "$PROJECTS" | jq -c '.[] | select(.forked_from_project == null)' | while read i; do
        PROJECT_ID=$(echo $i | jq -r '.id')
        PROJECT_NAME=$(echo $i | jq -r '.name')
        DEFAULT_BRANCH=$(echo $i | jq -r '.default_branch')
        NAMESPACE=$(echo $i | jq -r '.namespace.full_path')

        BRANCHES=("$DEFAULT_BRANCH")
        [[ "$DEFAULT_BRANCH" != "master" ]] && BRANCHES+=("master")
        [[ "$DEFAULT_BRANCH" != "main" ]] && BRANCHES+=("main")

        for BRANCH in "${BRANCHES[@]}"; do
            BRANCH_PAGE=1

            while :; do
                COMMITS=$(curl -s "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/repository/commits?private_token=$TOKEN&per_page=100&page=$BRANCH_PAGE&ref_name=$BRANCH")

                if [ -z "$COMMITS" ] || [ "$COMMITS" = "[]" ]; then
                    break
                fi

                echo "$COMMITS" | jq -c '.[]' | while read j; do
                    COMMIT_HASH=$(echo $j | jq -r '.id')

                    if grep -q "$COMMIT_HASH" "$PROCESSED_COMMITS_FILE"; then
                        continue
                    fi

                    echo "$COMMIT_HASH" >> "$PROCESSED_COMMITS_FILE"

                    AUTHOR_NAME=$(echo $j | jq -r '.author_name')
                    COMMIT_DATE=$(echo $j | jq -r '.committed_date')
                    COMMIT_MESSAGE=$(echo $j | jq -r '.title' | sed -e 's/'\''/\'\''/g' | sed -e 's/\"/\\\"/g')
                    IS_MERGE_COMMIT=$(echo $j | jq -r '.parent_ids | length > 1')

                    echo "('$NAMESPACE', '$PROJECT_NAME', '$AUTHOR_NAME', '$COMMIT_DATE', '$COMMIT_HASH', \"$COMMIT_MESSAGE\", -2, -2, $IS_MERGE_COMMIT)," >> "$OUTPUT_FILE"

                    # ファイルの行数を確認し、MAX_LINESを超えたらデータを投入してファイルを初期化
                    CURRENT_LINES=$(wc -l < "$OUTPUT_FILE")
                    if [ "$CURRENT_LINES" -ge "$MAX_LINES" ]; then
                        sed -i '$ s/,$/;/' "$OUTPUT_FILE"  # 最後のコンマをセミコロンに変更
                        # SnowSQLでデータを投入
                        snowsql -f "$OUTPUT_FILE"
                        # 出力ファイルの初期化
                        echo "INSERT INTO commits (group_name, project_name, author_name, commit_date, commit_hash, commit_message, added_lines, deleted_lines, is_merge_commit) VALUES" > "$OUTPUT_FILE"
                    fi
                done
                ((BRANCH_PAGE++))
            done
        done
    done
    ((PAGE++))
done

# ループ終了後、残りのデータがあれば投入
if [ -s "$OUTPUT_FILE" ]; then
    sed -i '$ s/,$/;/' "$OUTPUT_FILE"  # 最後のコンマをセミコロンに変更
    # SnowSQLでデータを投入
    snowsql -f "$OUTPUT_FILE"
fi

# 処理済みコミットファイルのクリーンアップ
rm "$PROCESSED_COMMITS_FILE"
