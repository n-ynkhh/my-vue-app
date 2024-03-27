#!/bin/bash

# GitLab APIのホスト名と個人アクセストークンを設定
GITLAB_HOST="https://gitlab.example.com"
PERSONAL_ACCESS_TOKEN="your_personal_access_token_here"

# 実行時の引数から日付を取得、指定がなければ前日の日付を使用
TARGET_DATE=${1:-$(date -d "yesterday" '+%Y-%m-%d')}

# APIからプロジェクトのリストを取得する関数
get_projects() {
    local page=1
    local per_page=100
    while : ; do
        local response=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects?page=$page&per_page=$per_page")
        echo "$response"
        if [ "$(echo $response | jq '. | length')" -lt $per_page ]; then
            break
        fi
        ((page++))
    done
}

# APIから特定のプロジェクトのパイプラインを取得する関数
get_pipelines() {
    local project_id=$1
    local page=1
    local per_page=100
    while : ; do
        local response=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects/$project_id/pipelines?page=$page&per_page=$per_page&updated_after=${TARGET_DATE}T00:00:00Z&updated_before=${TARGET_DATE}T23:59:59Z")
        echo "$response"
        if [ "$(echo $response | jq '. | length')" -lt $per_page ]; then
            break
        fi
        ((page++))
    done
}

# APIから特定のパイプラインのジョブを取得する関数
get_jobs() {
    local project_id=$1
    local pipeline_id=$2
    local page=1
    local per_page=100
    while : ; do
        local response=$(curl -s --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects/$project_id/pipelines/$pipeline_id/jobs?page=$page&per_page=$per_page")
        echo "$response"
        if [ "$(echo $response | jq '. | length')" -lt $per_page ]; then
            break
        fi
        ((page++))
    done
}

# 全てのプロジェクトを取得
projects=$(get_projects)

# プロジェクトのIDと名前を取得してループ
echo "$projects" | jq -c '.[] | {id, name}' | while read project; do
    project_id=$(echo $project | jq '.id')
    project_name=$(echo $project | jq -r '.name')

    # プロジェクトのパイプラインを取得
    pipelines=$(get_pipelines $project_id)

    # パイプラインIDを取得してループ
    echo "$pipelines" | jq -r '.[] | .id' | while read pipeline_id; do
        # パイプラインのジョブを取得
        jobs=$(get_jobs $project_id $pipeline_id)

        # ジョブ情報をCSV形式で出力
        echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | [
            .id,
            .pipeline.id,
            $project_id,
            $project_name,
            .ref,
            .name,
            .status,
            .stage,
            (.tag_list | join(",")),
            .web_url,
            .created_at,
            .started_at,
            .finished_at,
            .user.id,
            .user.name,
            .runner.description
        ] | @csv' >> jobs.csv
    done
done

echo "ジョブ情報を${TARGET_DATE}の日


#!/bin/bash

# GitLab APIのホスト名と個人アクセストークンを設定
GITLAB_HOST="https://gitlab.example.com"
PERSONAL_ACCESS_TOKEN="your_personal_access_token_here"

# 実行時の引数から日付を取得、指定がなければ前日の日付を使用
TARGET_DATE=${1:-$(date -d "yesterday" '+%Y-%m-%d')}

# ここにジョブ情報を収集する関数を配置（省略）

# 全てのプロジェクトを取得し、ジョブ情報をCSVに保存するロジック（省略）

# CSVファイルからSQL INSERT文を生成する
generate_insert_sql() {
    local sql_file="insert_jobs_${TARGET_DATE}.sql"
    echo "USE DATABASE your_database_name;" > "$sql_file"
    echo "USE SCHEMA your_schema_name;" >> "$sql_file"
    echo "BEGIN TRANSACTION;" >> "$sql_file"

    while IFS=, read -r job_id pipeline_id project_id project_name branch_name job_name job_status stage_name tag_list web_url created_at started_at finished_at user_id user_name runner_name; do
        echo "INSERT INTO your_table_name (job_id, pipeline_id, project_id, project_name, branch_name, job_name, job_status, stage_name, tag_list, web_url, created_at, started_at, finished_at, user_id, user_name, runner_name) VALUES ('$job_id', '$pipeline_id', '$project_id', '$project_name', '$branch_name', '$job_name', '$job_status', '$stage_name', '$tag_list', '$web_url', '$created_at', '$started_at', '$finished_at', '$user_id', '$user_name', '$runner_name');" >> "$sql_file"
    done < jobs.csv

    echo "COMMIT;" >> "$sql_file"
    echo "SQLファイルが生成されました: $sql_file"
}

# SQLファイルを生成
generate_insert_sql

# SnowSQLでSQLファイルを実行
snowsql -f "insert_jobs_${TARGET_DATE}.sql"

echo "Snowflakeへのデータインポートが完了しました。"
