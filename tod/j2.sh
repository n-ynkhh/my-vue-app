#!/bin/bash

# GitLab APIのホスト名と個人アクセストークンを設定
GITLAB_HOST="https://gitlab.example.com"
PERSONAL_ACCESS_TOKEN="your_personal_access_token_here"

# 実行時の引数から日付を取得、指定がなければ前日の日付を使用
TARGET_DATE=${1:-$(date -d "yesterday" '+%Y-%m-%d')}

# SQLファイル名を指定
SQL_FILE="insert_jobs_${TARGET_DATE}.sql"

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

# SQLファイルの初期化
> "$SQL_FILE"

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

        # ジョブ情報をSQL INSERT文として出力
        echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | "INSERT INTO your_table_name (job_id, pipeline_id, project_id, project_name, branch_name, job_name, job_status, stage_name, tag_list, web_url, created_at, started_at, finished_at, user_id, user_name, runner_name) VALUES (\(.id), \(.pipeline.id), \($project_id), \($project_name), \(.ref), \(.name), \(.status), \(.stage), \((.tag_list | join(","))), \(.web_url), \(.created_at), \(.started_at), \(.finished_at), \(.user.id), \(.user.name), \((if .runner then .runner.description else "N/A" end)));" ' >> "$SQL_FILE"
    done
done

echo "SQLファイルが生成されました: $SQL_FILE"
