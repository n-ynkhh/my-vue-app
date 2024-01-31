# 以前のスクリプトの設定...

# SQLコマンドを生成する部分を修正
echo "$merge_requests" | jq -r --arg project_name "$project_name" --arg namespace_path "$namespace_path" \
    '.[] | "MERGE INTO your_merge_requests_table USING (SELECT '\''\(.id)'\'' AS mr_id, '\''\($namespace_path)'\'' AS group_name, '\''\($project_name)'\'' AS project_name, '\''\(.title)'\'' AS title, '\''\(.created_at)'\'' AS created_at, '\''\(.state)'\'' AS state, '\''\(.author.username)'\'' AS author, " + (if .merged_at == null then "NULL" else "'\''\(.merged_at)'\''" end) + " AS merged_at, '\''\(.source_branch)'\'' AS source_branch, '\''\(.web_url)'\'' AS mr_url) AS src ON your_merge_requests_table.mr_id = src.mr_id AND your_merge_requests_table.group_name = src.group_name AND your_merge_requests_table.project_name = src.project_name WHEN MATCHED THEN UPDATE SET title = src.title, created_at = src.created_at, state = src.state, author = src.author, merged_at = src.merged_at, source_branch = src.source_branch, mr_url = src.mr_url WHEN NOT MATCHED THEN INSERT (mr_id, group_name, project_name, title, created_at, state, author, merged_at, source_branch, mr_url) VALUES (src.mr_id, src.group_name, src.project_name, src.title, src.created_at, src.state, src.author, src.merged_at, src.source_branch, src.mr_url);"'

# 以前のスクリプトの処理の終了...
