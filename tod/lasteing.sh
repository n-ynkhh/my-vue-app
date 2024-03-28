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
projects=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects?per_page=100")

# プロジェクトのIDと名前を取得してループ
echo "$projects" | jq -c '.[] | {id, name}' | while read project; do
    project_id=$(echo $project | jq '.id')
    project_name=$(echo $project | jq -r '.name')

    # プロジェクトのパイプラインを取得
    pipelines=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects/$project_id/pipelines?updated_after=${TARGET_DATE}T00:00:00Z&updated_before=${TARGET_DATE}T23:59:59Z&per_page=100")

    # パイプラインIDを取得してループ
    echo "$pipelines" | jq -r '.[] | .id' | while read pipeline_id; do
        # パイプラインのジョブを取得
        jobs=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects/$project_id/pipelines/$pipeline_id/jobs?per_page=100")

        # ジョブ情報からSQL INSERT文を生成してファイルに書き込み
        echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | "INSERT INTO your_table_name (job_id, pipeline_id, project_id, project_name, branch_name, job_name, job_status, stage_name, tag_list, web_url, created_at, started_at, finished_at, erased_at, duration, queued_duration, user_id, user_name, runner_name) VALUES (\(.id), \(.pipeline.id), \($project_id), \($project_name), \(.ref), \(.name), \(.status), \(.stage), \((.tag_list | join(","))), \(.web_url), \(.created_at), \(.started_at), \(.finished_at), \(.erased_at // "null"), \(.duration // "null"), \(.queued_duration // "null"), \(.user.id), \(.user.name), \((if .runner then .runner.description else "N/A" end)));" ' >> "$SQL_FILE"
        LINE_COUNTER=$((LINE_COUNTER + $(echo "$jobs" | jq '. | length')))

        # 1000行ごとにSnowflakeにデータを投入し、ファイルを初期化
        if [ $LINE_COUNTER -ge 1000 ]; then
            # SnowSQLでSQLファイルを実行
            snowsql -f "$SQL_FILE" -o friendly=false -o output_format=plain
            echo "$SQL_FILE のインポートが完了しました。"

            # ファイルの初期化
            > "$SQL_FILE"
            LINE_COUNTER=0
        fi
    done
done

# 残ったデータがあれば最後にもう一度インポート
if [ $LINE_COUNTER -gt 0 ]; then
    # SnowSQLでSQLファイルを実行
    snowsql -f "$SQL_FILE" -o friendly=false -o output_format=plain
    echo "$SQL_FILE のインポートが完了しました。"
fi
