echo "" >> "$SQL_FILE"

# ファイルの最後のカンマをセミコロンに置き換える
sed -i '$ s/,$/;/' "$SQL_FILE"


echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | "('\''\(.id)'\'', '\''\(.pipeline.id)'\'', '\''\($project_id)'\'', '\''\($project_name)'\'', '\''\(.ref)'\'', '\''\(.name)'\'', '\''\(.status)'\'', '\''\(.stage)'\'', '\''\((.tag_list | join(",")))'\'', '\''\(.web_url)'\'', '\''\(.created_at)'\'', '\''\(.started_at)'\'', '\''\((if .finished_at == null then "NULL" else "'\(.finished_at)'" end)'\'', '\''\((if .erased_at == null then "NULL" else "'\(.erased_at)'" end)'\'', '\''\((if .duration == null then "NULL" else "'\(.duration)'" end)'\'', '\''\((if .queued_duration == null then "NULL" else "'\(.queued_duration)'" end)'\'', '\''\(.user.id)'\'', '\''\(.user.name)'\'', '\''\((if .runner then .runner.description else "N/A" end))'\''),"' >> "$SQL_FILE"


echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | "('\''\(.id)'\'', '\''\(.pipeline.id)'\'', '\''\($project_id)'\'', '\''\($project_name)'\'', '\''\(.ref)'\'', '\''\(.name)'\'', '\''\(.status)'\'', '\''\(.stage)'\'', '\''\((.tag_list | join(",")))'\'', '\''\(.web_url)'\'', '\''\(.created_at)'\'', '\''\(.started_at)'\'', '\''\((if .finished_at == null then "NULL" else "'\(.finished_at)'" end)'\'', '\''\((if .erased_at == null then "NULL" else "'\(.erased_at)'" end)'\'', '\''\((if .duration == null then "NULL" else .duration end)'\'', '\''\((if .queued_duration == null then "NULL" else .queued_duration end)'\'', '\''\(.user.id)'\'', '\''\(.user.name)'\'', '\''\((if .runner then .runner.description else "N/A" end))'\''),"' >> "$SQL_FILE"



# ジョブ情報からVALUES部分を生成し、ファイルに書き込む
echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | "('\''\(.id)'\'', '\''\(.pipeline.id)'\'', '\''\($project_id)'\'', '\''\($project_name)'\'', '\''\(.ref)'\'', '\''\(.name)'\'', '\''\(.status)'\'', '\''\(.stage)'\'', '\''\((.tag_list | join(",")))'\'', '\''\(.web_url)'\'', '\''\(.created_at)'\'', '\''\(.started_at)'\'', '\''\(.finished_at)'\'', '\''\(.erased_at // "null")'\'', '\''\(.duration // "null")'\'', '\''\(.queued_duration // "null")'\'', '\''\(.user.id)'\'', '\''\(.user.name)'\'', '\''\((if .runner then .runner.description else "N/A" end))'\''),"' >> "$SQL_FILE"

# ジョブ情報からVALUES部分を生成し、ファイルに書き込む
echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | "('\''\(.id)'\'', '\''\(.pipeline.id)'\'', '\''\($project_id)'\'', '\''\($project_name)'\'', '\''\(.ref)'\'', '\''\(.name)'\'', '\''\(.status)'\'', '\''\(.stage)'\'', '\''\((.tag_list | join(",")))'\'', '\''\(.web_url)'\'', '\''\(.created_at)'\'', '\''\(.started_at)'\'', '\''\(.finished_at)'\'', \(.erased_at // "null"), \(.duration // "null"), \(.queued_duration // "null"), '\''\(.user.id)'\'', '\''\(.user.name)'\'', \((if .runner then '\''\(.runner.description)'\'' else "null" end))),' " >> "$SQL_FILE"

# ジョブ情報からVALUES部分を生成し、ファイルに書き込む
echo "$jobs" | jq -r --arg project_id "$project_id" --arg project_name "$project_name" '.[] | "('\''\(.id)'\'', '\''\(.pipeline.id)'\'', '\''\($project_id)'\'', '\''\($project_name)'\'', '\''\(.ref)'\'', '\''\(.name)'\'', '\''\(.status)'\'', '\''\(.stage)'\'', '\''\((.tag_list | join("\",\"")))'\'', '\''\(.web_url)'\'', '\''\(.created_at)'\'', '\''\(.started_at)'\'', '\''\(.finished_at)'\'', " + (if .erased_at then "'\''\(.erased_at)'\''" else "null") + ", " + (if .duration then "\(.duration)" else "null") + ", " + (if .queued_duration then "\(.queued_duration)" else "null") + ", '\''\(.user.id)'\'', '\''\(.user.name)'\'', " + (if .runner then "'\''\(.runner.description)'\''" else "null") + "),' " >> "$SQL_FILE"


'\''\((if .queued_duration == null then "NULL" else ("\(.queued_duration)") end)'\'' 


#!/bin/bash

# GitLabの設定
BASE_URL="https://gitlab.com/api/v4" # GitLabインスタンスのURL
PROJECT_ID="your_project_id" # プロジェクトID
PRIVATE_TOKEN="your_private_token" # GitLabのアクセストークン
DATE="2024-03-29" # 指定された日付 (YYYY-MM-DD)

# パイプラインIDの配列 (例: PIPELINE_IDS=("1234" "5678"))
PIPELINE_IDS=("pipeline_id_1" "pipeline_id_2")

# 指定日の0時と23時59分をISO 8601形式で設定
START_DATE="${DATE}T00:00:00Z"
END_DATE="${DATE}T23:59:59Z"

# 各パイプラインに対してループ処理
for PIPELINE_ID in "${PIPELINE_IDS[@]}"; do
    echo "Processing pipeline: $PIPELINE_ID"

    # APIを使用して指定された時間範囲内のジョブを取得
    jobs=$(curl --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$BASE_URL/projects/$PROJECT_ID/pipelines/$PIPELINE_ID/jobs?updated_after=$START_DATE&updated_before=$END_DATE")

    # 指定された日に完了したジョブをフィルタリング
    finished_jobs=$(echo "$jobs" | jq --arg START_DATE "$START_DATE" --arg END_DATE "$END_DATE" '.[] | select(.finished_at | . >= $START_DATE and . <= $END_DATE)')

    # フィルタリングされたジョブを出力または処理
    echo "$finished_jobs"
    # 必要に応じてここで変数にジョブ情報を追加する処理を行う
done


#!/bin/bash

# 必要な変数の設定
DATE="2024-03-29" # 例: "YYYY-MM-DD"
START_DATE="${DATE}T00:00:00Z"
END_DATE="${DATE}T23:59:59Z"
SQL_FILE="output_file.sql" # 出力ファイルのパス

# jobs変数からフィルタリングしてファイルに書き込む
echo "$jobs" | jq -r --arg START_DATE "$START_DATE" --arg END_DATE "$END_DATE" --arg project_id "$PROJECT_ID" --arg project_name "$PROJECT_NAME" \
'.[] | select(.finished_at | . >= $START_DATE and . <= $END_DATE) | 
"('\''\(.id)'\'', '\''\(.pipeline.id)'\'', '\''\($project_id)'\'', '\''\($project_name)'\'', '\''\(.ref)'\'', '\''\(.name)'\'', '\''\(.status)'\'', '\''\(.stage)'\'', '\''\((.tag_list | join(",")))'\'', '\''\(.web_url)'\'', '\''\(.created_at)'\'', '\''\(.started_at)'\'', '\''\(.finished_at)'\'', '\''\(.erased_at // "null")'\'', '\''\(.duration // "null")'\'', '\''\(.queued_duration // "null")'\'', '\''\(.user.id)'\'', '\''\(.user.name)'\'', '\''\((if .runner then .runner.description else "N/A" end))'\''),"' >> "$SQL_FILE"

