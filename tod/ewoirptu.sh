jobs=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects/$project_id/pipelines/$pipeline_id/jobs?page=$job_page&per_page=$per_page")
                    job_count=$(echo "$jobs" | jq '. | length')
                    if [ "$job_count" -eq 0 ]; then
                        break
                    fi

                    # 新しいINSERT文の開始
                    if [ "$NEW_INSERT" -eq 1 ]; then
                        echo "INSERT INTO your_table_name (job_id, pipeline_id, project_id, project_name, branch_name, job_name, job_status, stage_name, tag_list, web_url, created_at, started_at, finished_at, erased_at, duration, queued_duration, user_id, user_name, runner_name) VALUES" >> "$SQL_FILE"
                        NEW_INSERT=0
                    fi

                    # ジョブ情報からVALUES部分を生成
                    echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | "(\(.id), \(.pipeline.id), \($project_id), \($project_name), \(.ref), \(.name), \(.status), \(.stage), \((.tag_list | join(","))), \(.web_url), \(.created_at), \(.started_at), \(.finished_at), \(.erased_at // "null"), \(.duration // "null"), \(.queued_duration // "null"), \(.user.id), \(.user.name), \((if .runner then .runner.description else "N/A" end))"' | awk '{if(NR>1)print ","$0; else print $0}' >> "$SQL_FILE"

                    LINE_COUNTER=$((LINE_COUNTER + $job_count))

                    # 1000行ごとにバッチを終了し、次のバッチを開始
                    if [ $LINE_COUNTER -ge 1000 ]; then
                        echo ";" >> "$SQL_FILE"  # 現在のINSERT文を終了
                        snowsql -f "$SQL_FILE" -o friendly=false -o output_format=plain
                        echo "$SQL_FILE のインポートが完了しました。"
                        > "$SQL_FILE"  # SQLファイルを初期化
                        LINE_COUNTER=0
                        NEW_INSERT=1
                    fi

                    ((job_page++))
