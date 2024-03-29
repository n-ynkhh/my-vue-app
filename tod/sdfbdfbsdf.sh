#!/bin/bash

# GitLab APIのホスト名と個人アクセストークンを設定
GITLAB_HOST="https://gitlab.example.com"
PERSONAL_ACCESS_TOKEN="your_personal_access_token_here"

# 実行時の引数から日付を取得、指定がなければ前日の日付を使用
TARGET_DATE=${1:-$(date -d "yesterday" '+%Y-%m-%d')}

# SQLファイル名を指定
SQL_FILE="insert_jobs_${TARGET_DATE}.sql"

# SQLファイルの行数カウンタ
LINE_COUNTER=0

# SQLファイルの初期化
> "$SQL_FILE"

# 全てのプロジェクトを取得
page=1
per_page=100
while : ; do
    projects=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects?page=$page&per_page=$per_page")
    project_count=$(echo "$projects" | jq '. | length')
    if [ "$project_count" -eq 0 ]; then
        break
    fi

    # プロジェクトのIDと名前を取得してループ
    echo "$projects" | jq -c '.[] | {id, name}' | while read project; do
        project_id=$(echo $project | jq '.id')
        project_name=$(echo $project | jq -r '.name')

        # 各プロジェクトのパイプラインを取得
        pipeline_page=1
        while : ; do
            pipelines=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects/$project_id/pipelines?updated_after=${TARGET_DATE}T00:00:00Z&updated_before=${TARGET_DATE}T23:59:59Z&page=$pipeline_page&per_page=$per_page")
            pipeline_count=$(echo "$pipelines" | jq '. | length')
            if [ "$pipeline_count" -eq 0 ]; then
                break
            fi

            # パイプラインIDを取得してループ
            echo "$pipelines" | jq -r '.[] | .id' | while read pipeline_id; do
                # 各パイプラインのジョブを取得
                job_page=1
                while : ; do
                    jobs=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects/$project_id/pipelines/$pipeline_id/jobs?page=$job_page&per_page=$per_page")
                    job_count=$(echo "$jobs" | jq '. | length')
                    if [ "$job_count" -eq 0 ]; then
                        break
                    fi

                    # ジョブ情報からSQL INSERT文を生成してファイルに書き込み
                    echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | "INSERT INTO your_table_name (job_id, pipeline_id, project_id, project_name, branch_name, job_name, job_status, stage_name, tag_list, web_url, created_at, started_at, finished_at, erased_at, duration, queued_duration, user_id, user_name, runner_name) VALUES (\(.id), \(.pipeline.id), \($project_id), \($project_name), \(.ref), \(.name), \(.status), \(.stage), \((.tag_list | join(","))), \(.web_url), \(.created_at), \(.started_at), \(.finished_at), \(.erased_at // "null"), \(.duration // "null"), \(.queued_duration // "null"), \(.user.id), \(.user.name), \((if .runner then .runner.description else "N/A" end)));" ' >> "$SQL_FILE"
                    LINE_COUNTER=$((LINE_COUNTER + $job_count))

                    # 1000行ごとにSnowflakeにデータを投入し、ファイルを初期化
                    if [ $LINE_COUNTER -ge 1000 ]; then
                        # SnowSQLでSQLファイルを実行
                        snowsql -f "$SQL_FILE" -o friendly=false -o output_format=plain
                        echo "$SQL_FILE のインポートが完了しました。"

                        # ファイルの初期化
                        > "$SQL_FILE"
                        LINE_COUNTER=0
                    fi

                    ((job_page++))
                done
            done

            ((pipeline_page++))
        done
    done

    if [ "$project_count" -lt $per_page ]; then
        break
    fi
    ((page++))
done

# 残ったデータがあれば最後にもう一度インポート
if [ $LINE_COUNTER -gt 0 ]; then
    # SnowSQLでSQLファイルを実行
    snowsql -f "$SQL_FILE" -o friendly=false -o output_format=plain
    echo "$SQL_FILE のインポートが完了しました。"
fi

                    # バルクインサートの値部分を生成
                    VALUES_PART=$(echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | "(\(.id), \(.pipeline.id), \($project_id), \($project_name), \(.ref), \(.name), \(.status), \(.stage), \((.tag_list | join(","))), \(.web_url), \(.created_at), \(.started_at), \(.finished_at), \(.erased_at // "null"), \(.duration // "null"), \(.queued_duration // "null"), \(.user.id), \(.user.name), \((if .runner then .runner.description else "N/A" end))"')

                    # 最後のレコードの末尾にコンマを付けないように調整
                    VALUES=$(echo "$VALUES_PART" | awk '{if(NR>1)print ","$0; else print $0}' | awk 'NR>1{print prev}{prev=$0}END{print substr(prev, 1, length(prev))";"}')

                    # バルクインサートの値部分をファイルに書き込む
                    if [ "$BATCH_START" -eq 1 ]; then
                        echo "INSERT INTO your_table_name (job_id, pipeline_id, project_id, project_name, branch_name, job_name, job_status, stage_name, tag_list, web_url, created_at, started_at, finished_at, erased_at, duration, queued_duration, user_id, user_name, runner_name) VALUES" >> "$SQL_FILE"
                        BATCH_START=0
                    else
                        echo "," >> "$SQL_FILE"
                    fi
                    echo "$VALUES" >> "$SQL_FILE"

                    LINE_COUNTER=$((LINE_COUNTER + $job_count))

                    # 1000行ごとにSnowflakeにデータを投入し、ファイルを初期化
                    if [ $LINE_COUNTER -ge 1000 ]; then
                        snowsql -f "$SQL_FILE" -o friendly=false -o output_format=plain
                        echo "$SQL_FILE のインポートが完了しました。"
                        > "$SQL_FILE"
                        LINE_COUNTER=0
                        BATCH_START=1
                    fi
