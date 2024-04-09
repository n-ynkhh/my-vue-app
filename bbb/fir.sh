process_merge_requests() {
    project_id=$1
    project_name=$2
    namespace_path=$3
    insert_started=false

    # 指定年月に作成されたMRのINSERT文を生成
    page=1
    while : ; do
        merge_requests=$(curl -s "https://gitlab.com/api/v4/projects/$project_id/merge_requests?private_token=$PRIVATE_TOKEN&created_after=$START_DATE&created_before=$END_DATE&per_page=$PER_PAGE&page=$page")
        if [ "$page" -eq 1 ] && [ "$(echo "$merge_requests" | jq '. | length')" -gt 0 ]; then
            echo "INSERT INTO your_merge_requests_table (mr_id, group_name, project_name, title, created_at, state, author, merged_at, source_branch, mr_url, comments_count) VALUES" >> $SQL_FILE
            insert_started=true
        fi
        if [ "$(echo "$merge_requests" | jq '. | length')" -eq 0 ]; then
            break
        fi

        for mr_id in $(echo "$merge_requests" | jq '.[] | .id'); do
            # 各MRに対してコメント数を取得
            comments=$(curl -s "https://gitlab.com/api/v4/projects/$project_id/merge_requests/$mr_id/notes?private_token=$PRIVATE_TOKEN")
            comments_count=$(echo "$comments" | jq '. | length')

            # MR情報とコメント数を組み合わせてSQLファイルに書き込む
            echo "$merge_requests" | jq -r --arg project_name "$project_name" --arg namespace_path "$namespace_path" --arg comments_count "$comments_count" \
                '.[] | select(.id == '"$mr_id"') | "(\(.id), '\''\($namespace_path)'\'', '\''\($project_name)'\'', '\''\(.title | gsub("'"'"'; "'"'"''"'"'"))'\'', '\''\(.created_at)'\'', '\''\(.state)'\'', '\''\(.author.username)'\'', '\''\(.merged_at // "NULL")'\'', '\''\(.source_branch)'\'', '\''\(.web_url)'\'', '\''\($comments_count)'\''),"' >> $SQL_FILE
        done

        ((page++))
    done

    # 最後のカンマを削除し、セミコロンを追加
    if [ "$insert_started" = true ]; then
        sed -i '$ s/,$/;/' $SQL_FILE
    fi
}
