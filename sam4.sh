#!/bin/bash

# GitLabのプライベートトークン設定
PRIVATE_TOKEN="YOUR_PRIVATE_TOKEN"
PER_PAGE=100
OUTPUT_FILE="merge_requests_details.csv"

# 引数から年月を取得、未指定の場合は前月を設定
if [ -z "$1" ]; then
    YEAR_MONTH=$(date -d "1 month ago" '+%Y-%m')
else
    YEAR_MONTH=$1
fi

# 指定された年月の初日と最終日を計算
START_DATE=$(date -d "$YEAR_MONTH-01" '+%Y-%m-%d')
END_DATE=$(date -d "$YEAR_MONTH-01 +1 month -1 day" '+%Y-%m-%d')

# 出力ファイルのヘッダーを設定
echo "Group Name,Project Name,MR ID,MR Title,Created At,State,Author,Merged At,Source Branch,MR URL" > $OUTPUT_FILE

# すべてのプロジェクトIDを取得し、それぞれのプロジェクトのマージリクエストを取得
PAGE=1
while : ; do
    projects=$(curl -s "https://gitlab.com/api/v4/projects?private_token=$PRIVATE_TOKEN&page=$PAGE&per_page=$PER_PAGE" | jq -r '.[] | select(.forked_from_project == null) | [.id, .name, .namespace.full_path] | @csv')
    if [ -z "$projects" ]; then
        break
    fi

    echo "$projects" | while IFS= read -r project; do
        IFS=',' read -r project_id project_name namespace_path <<< "$project"
        mr_page=1
        while : ; do
            merge_requests=$(curl -s "https://gitlab.com/api/v4/projects/$project_id/merge_requests?private_token=$PRIVATE_TOKEN&created_after=$START_DATE&created_before=$END_DATE&page=$mr_page&per_page=$PER_PAGE")
            
            if [[ -n "$merge_requests" && $(echo "$merge_requests" | jq empty 2> /dev/null) ]]; then
                echo "$merge_requests" | jq -r --arg project_name "$project_name" --arg namespace_path "$namespace_path" '.[] | select(.id != null) | [$namespace_path, $project_name, (.id|tostring), .title, .created_at, .state, .author.username, .merged_at, .source_branch, .web_url] | @csv' >> $OUTPUT_FILE

                if [ ! $(echo "$merge_requests" | jq '.[] | select(.id != null)') ]; then
                    ((mr_page++))
                    continue
                fi
            fi

            ((mr_page++))
            if [ $(echo "$merge_requests" | jq '. | length') -lt $PER_PAGE ]; then
                break
            fi
        done
    done

    ((PAGE++))
    if [ $(echo "$projects" | jq '. | length') -lt $PER_PAGE ]; then
        break
    fi
done
