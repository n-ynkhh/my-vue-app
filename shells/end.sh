# プロジェクトごとにマージリクエストを処理
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

    # プロジェクト一覧のページネーション処理の修正
    response_headers=$(curl -sI "https://gitlab.com/api/v4/projects?private_token=$PRIVATE_TOKEN&per_page=$PER_PAGE&page=$((project_page+1))")
    next_page=$(echo "$response_headers" | grep -Fi x-next-page | awk '{print $2}' | tr -d '\r')
    if [ -z "$next_page" ] || [ "$next_page" = "0" ]; then
        break
    fi
    ((project_page++))
done
