        while : ; do
            merge_requests=$(curl -s "https://gitlab.com/api/v4/projects/$project_id/merge_requests?private_token=$PRIVATE_TOKEN&created_after=$START_DATE&created_before=$END_DATE&page=$mr_page&per_page=$PER_PAGE")
            
            # merge_requestsが有効なJSONであるかを確認
            if [[ -n "$merge_requests" && $(echo "$merge_requests" | jq empty 2> /dev/null) ]]; then
                # 各マージリクエストのIDが存在するか確認し、存在する場合のみファイルへ出力
                echo "$merge_requests" | jq -r --arg project_name "$project_name" --arg namespace_path "$namespace_path" '.[] | select(.id != null) | [$namespace_path, $project_name, (.id|tostring), .title, .created_at, .state, .author.username, .merged_at, .source_branch, .web_url] | @csv' >> $OUTPUT_FILE

                # マージリクエストが一つも処理されなかった場合、次のページに進む
                if [ ! $(echo "$merge_requests" | jq '.[] | select(.id != null)') ]; then
                    ((mr_page++))
                    continue
                fi
            fi

            ((mr_page++))
            # マージリクエストの数がページあたりの最大数より少ない場合、ループを抜ける
            if [ $(echo "$merge_requests" | jq '. | length') -lt $PER_PAGE ]; then
                break
            fi
        done
