#!/bin/bash

# トークンとGitLabのURLを設定
TOKEN="your_private_token_here"
OUTPUT_FILE="commits.sql"  # 出力ファイル
PAGE=1  # 初期ページ

# 出力ファイルの初期化
echo "INSERT INTO commits (group_name, project_name, author_name, commit_date, commit_hash, commit_message, added_lines, deleted_lines, is_merge_commit) VALUES" > "$OUTPUT_FILE"

# プロジェクト情報の取得とページネーション
while :; do
    PROJECTS=$(curl -s "https://gitlab.example.com/api/v4/projects?private_token=$TOKEN&per_page=100&page=$PAGE&simple=true&membership=true")

    # プロジェクトがなければループを抜ける
    if [ -z "$PROJECTS" ] || [ "$PROJECTS" = "[]" ]; then
        break
    fi

    echo "$PROJECTS" | jq -c '.[] | select(.forked_from_project == null)' | while read i; do
        PROJECT_ID=$(echo $i | jq -r '.id')
        PROJECT_NAME=$(echo $i | jq -r '.name')
        DEFAULT_BRANCH=$(echo $i | jq -r '.default_branch')
        NAMESPACE=$(echo $i | jq -r '.namespace.full_path')

        # ブランチの対象を絞る
        BRANCHES=("$DEFAULT_BRANCH")
        [[ "$DEFAULT_BRANCH" != "master" ]] && BRANCHES+=("master")
        [[ "$DEFAULT_BRANCH" != "main" ]] && BRANCHES+=("main")

        for BRANCH in "${BRANCHES[@]}"; do
            BRANCH_PAGE=1  # ブランチごとのページネーション初期化

            while :; do
                COMMITS=$(curl -s "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/repository/commits?private_token=$TOKEN&per_page=100&page=$BRANCH_PAGE&ref_name=$BRANCH")

                if [ -z "$COMMITS" ] || [ "$COMMITS" = "[]" ]; then
                    break
                fi

                echo "$COMMITS" | jq -c '.[]' | while read j; do
                    COMMIT_HASH=$(echo $j | jq -r '.id')
                    AUTHOR_NAME=$(echo $j | jq -r '.author_name')
                    COMMIT_DATE=$(echo $j | jq -r '.committed_date')
                    COMMIT_MESSAGE=$(echo $j | jq -r '.title' | sed -e 's/'\''/\'\''/g' | sed -e 's/\"/\\\"/g')
                    IS_MERGE_COMMIT=$(echo $j | jq -r '.parent_ids | length > 1')

                    # コミットごとの情報をファイルに出力
                    echo "('$NAMESPACE', '$PROJECT_NAME', '$AUTHOR_NAME', '$COMMIT_DATE', '$COMMIT_HASH', \"$COMMIT_MESSAGE\", -2, -2, $IS_MERGE_COMMIT)," >> "$OUTPUT_FILE"
                done
                ((BRANCH_PAGE++))
            done
        done
    done
    ((PAGE++))
done

# 最後のコンマを削除してSQLを終了する
sed -i '$ s/,$/;/' "$OUTPUT_FILE"
