echo "$COMMITS" | jq -c '.[] | select(.id != null)' | while read j; do
    COMMIT_ID=$(echo "$j" | jq -r '.id')
    if [ -n "$COMMIT_ID" ]; then
        # .id フィールドが存在する場合のみ、以下の処理を実行
        AUTHOR_NAME=$(echo "$j" | jq -r '.author_name')
        COMMIT_DATE=$(echo "$j" | jq -r '.committed_date')
        COMMIT_MESSAGE=$(echo "$j" | jq -r '.title' | sed -e "s/'/''/g" -e 's/\"/\\"/g')
        IS_MERGE_COMMIT=$(echo "$j" | jq -r '.parent_ids | length > 1')

        # コミットの詳細を取得して追加行数と削除行数を抽出
        COMMIT_DETAIL=$(curl -s "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/repository/commits/$COMMIT_ID?private_token=$TOKEN")
        ADDED_LINES=$(echo "$COMMIT_DETAIL" | jq '.stats.additions')
        DELETED_LINES=$(echo "$COMMIT_DETAIL" | jq '.stats.deletions')

        # SQL文を構築してファイルに追記
        INSERT_STMT="('$NAMESPACE', '$PROJECT_NAME', '$AUTHOR_NAME', '$COMMIT_DATE', '$COMMIT_HASH', '$COMMIT_MESSAGE', $ADDED_LINES, $DELETED_LINES, $IS_MERGE_COMMIT),\n"
        echo "$INSERT_STMT" >> "$OUTPUT_FILE"
    fi
done



COMMIT_MESSAGE=$(echo "$j" | jq -r '.title' | sed "s/'/''/g" | sed 's/"/\\"/g')
