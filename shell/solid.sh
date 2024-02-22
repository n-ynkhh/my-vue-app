while : ; do
    PROJECTS=$(curl --header "Private-Token: $TOKEN" "$GITLAB_URL/api/v4/projects?per_page=$PER_PAGE&page=$PAGE")
    PROJECTS_COUNT=$(echo "$PROJECTS" | jq 'length')
    if [ "$PROJECTS_COUNT" -eq 0 ]; then
        break
    fi

    echo "$PROJECTS" | jq -c '.[]' | while read i; do
        # プロジェクトレベルの処理
        # ...

        BRANCH_PAGE=1
        while : ; do
            BRANCHES=$(curl --header "Private-Token: $TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/repository/branches?per_page=$PER_PAGE&page=$BRANCH_PAGE")
            BRANCHES_COUNT=$(echo "$BRANCHES" | jq 'length')
            if [ "$BRANCHES_COUNT" -eq 0 ]; then
                break
            fi

            echo "$BRANCHES" | jq -c '.[]' | while read b; do
                # ブランチレベルの処理
                # ...

                COMMIT_PAGE=1
                while : ; do
                    COMMITS=$(curl --header "Private-Token: $TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/repository/commits?ref_name=$BRANCH_NAME&since=$START_DATE&until=$END_DATE&per_page=$PER_PAGE&page=$COMMIT_PAGE")
                    COMMITS_COUNT=$(echo "$COMMITS" | jq 'length')
                    if [ "$COMMITS_COUNT" -eq 0 ]; then
                        break
                    fi

                    echo "$COMMITS" | jq -c '.[]' | while read j; do
                        # コミットレベルの処理
                        # ...
                        
                        # 最初のレコードでなければカンマを追加
                        if [ "$FIRST_RECORD" = true ]; then
                            FIRST_RECORD=false
                        else
                            echo "," >> "$OUTPUT_FILE"
                        fi

                        # INSERT文の値部分を出力
                        echo -n "(\"$GROUP_NAME\", \"$PROJECT_NAME\", \"$BRANCH_NAME\", \"$AUTHOR_NAME\", \"$COMMIT_DATE\", \"$COMMIT_HASH\", \"$COMMIT_MESSAGE\", 0, 0, $IS_MERGE_COMMIT)" >> "$OUTPUT_FILE"
                    done
                    ((COMMIT_PAGE++))
                    FIRST_RECORD=true  # コミットの次のページに移動する前にリセット
                done
                FIRST_RECORD=true  # ブランチの次のページに移動する前にリセット
            done
            ((BRANCH_PAGE++))
        done
        FIRST_RECORD=true  # プロジェクトの次のページに移動する前にリセット
    done
    ((PAGE++))
done



echo "$COMMITS" | jq -c '.[]' 2>/dev/null || { echo "Failed to parse JSON: $COMMITS" >&2; continue; } | while read j; do
