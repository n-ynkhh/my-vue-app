#!/bin/bash

# GitLab APIのホスト名と個人アクセストークンを設定
GITLAB_HOST="https://gitlab.example.com"
PERSONAL_ACCESS_TOKEN="your_personal_access_token_here"

# 実行時の引数から日付を取得、指定がなければ前日の日付を使用
TARGET_DATE=${1:-$(date -d "yesterday" '+%Y-%m-%d')}

# SQLファイル名を指定
SQL_FILE="insert_jobs_${TARGET_DATE}.sql"

# レコードカウンタ
RECORD_COUNT=0

# ページネーションで全てのプロジェクトを取得
page=1
per_page=100
while : ; do
    projects=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects?page=$page&per_page=$per_page")
    project_count=$(echo "$projects" | jq '. | length')
    if [ "$project_count" -eq 0 ]; then
        break
    fi

    echo "$projects" | jq -c '.[] | {id, name}' | while read project; do
        project_id=$(echo $project | jq '.id')
        project_name=$(echo $project | jq -r '.name')

        pipeline_page=1
        while : ; do
            pipelines=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects/$project_id/pipelines?updated_after=${TARGET_DATE}T00:00:00Z&updated_before=${TARGET_DATE}T23:59:59Z&page=$pipeline_page&per_page=$per_page")
            pipeline_count=$(echo "$pipelines" | jq '. | length')
            if [ "$pipeline_count" -eq 0 ]; then
                break
            fi

            echo "$pipelines" | jq -r '.[] | .id' | while read pipeline_id; do
                job_page=1
                while : ; do
                    jobs=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects/$project_id/pipelines/$pipeline_id/jobs?page=$job_page&per_page=$per_page")
                    job_count=$(echo "$jobs" | jq '. | length')
                    if [ "$job_count" -eq 0 ]; then
                        break
                    fi

                    # INSERT文の開始
                    if [ "$RECORD_COUNT" -eq 0 ]; then
                        echo "INSERT INTO your_table_name (job_id, pipeline_id, project_id, project_name, branch_name, job_name, job_status, stage_name, tag_list, web_url, created_at, started_at, finished_at, erased_at, duration, queued_duration, user_id, user_name, runner_name) VALUES" > "$SQL_FILE"
                    fi

                    # ジョブ情報からVALUES部分を生成し、ファイルに書き込む
                    echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | "(\(.id), \(.pipeline.id), \($project_id), \($project_name), \(.ref), \(.name), \(.status), \(.stage), \((.tag_list | join(","))), \(.web_url), \(.created_at), \(.started_at), \(.finished_at), \(.erased_at // "null"), \(.duration // "null"), \(.queued_duration // "null"), \(.user.id), \(.user.name), \((if .runner then .runner.description else "N/A" end))),' >> "$SQL_FILE"

                    RECORD_COUNT=$((RECORD_COUNT + job_count))

                    # 1000レコードごとにバッチを終了し、ファイルをSnowflakeに投入
                    if [ "$RECORD_COUNT" -ge 1000 ]; then
                        # ファイルの最後尾の`,`を`;`に変更
                        sed -i '$ s/,$/;/' "$SQL_FILE"
                        snowsql -f "$SQL_FILE" -o friendly=false -o output_format=plain
                        echo "$SQL_FILE のインポートが完了しました。"
                        > "$SQL_FILE"  # SQLファイルを初期化
                        RECORD_COUNT=0  # カウンタをリセット
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

# 残りのレコードがあればインポート
if [ "$RECORD_COUNT" -gt 0 ]; then
    # ファイルの最後尾の`,`を`;`に変更
    sed -i '$ s/,$/;/' "$SQL_FILE"
    snowsql -f "$SQL_FILE" -o friendly=false -o output_format=plain
    echo "$SQL_FILE のインポートが完了しました。"
fi
