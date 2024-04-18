#!/bin/bash

# プロジェクトIDとマージリクエストIDの配列を設定
PROJECT_ID="your_project_id"
MERGE_REQUEST_IIDS=(1 2 3)  # 対象のマージリクエストIDをリスト

# GitLabのホストとアクセストークンを設定
GITLAB_HOST="https://gitlab.example.com"  # GitLabのホストURL
ACCESS_TOKEN="your_access_token"  # アクセストークン

# 各マージリクエストに対してループ処理
for MR_IID in "${MERGE_REQUEST_IIDS[@]}"; do
    echo "Processing merge request ID: $MR_IID"

    # GitLab APIを使用してコメントを取得
    COMMENTS=$(curl -s --header "PRIVATE-TOKEN: $ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/merge_requests/$MR_IID/notes?sort=asc")

    # 特定のユーザー以外からの最も古いコメントの日付を抽出
    cut_off_date=$(echo "$COMMENTS" | jq -c '[.[] | select(.author.id | tostring != "5" and tostring != "6" and .system == true)] | sort_by(.created_at) | .[0] | .created_at')

    # cut_off_dateが設定されている場合、それ以前のコメントだけを再度フィルタリング
    if [[ -n "$cut_off_date" ]]; then
        oldest_date=$(echo "$COMMENTS" | jq -c ".[] | select(.system == true and .created_at < $cut_off_date and (.body == \"aaaaa\" or .body | startswith(\"bbb\")))" | jq -s 'min_by(.created_at) | .created_at')

        # 最も古いコメントの作成日を出力
        if [[ -n "$oldest_date" ]]; then
            echo "Oldest valid comment for MR $MR_IID: $oldest_date"
        else
            echo "No valid comments found before cut-off date for MR $MR_IID"
        fi
    else
        echo "No comments from non-specified users found for MR $MR_IID"
    fi
done
