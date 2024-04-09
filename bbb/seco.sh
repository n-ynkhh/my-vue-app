#!/bin/bash

# GitLab のホスト名、プロジェクトID、MR ID、およびアクセストークンを設定
GITLAB_HOST="https://gitlab.example.com"
PROJECT_ID="your_project_id"
MR_ID="your_mr_id"
ACCESS_TOKEN="your_access_token"
EXCLUDED_USER_ID=12

# GitLab API から MR のコメントを取得
response=$(curl -s --header "PRIVATE-TOKEN: $ACCESS_TOKEN" "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/merge_requests/$MR_ID/notes")

# MR 作成者自身のコメント、特定のユーザーのコメント、およびシステムコメントを除外してコメント数をカウント
comment_count=$(echo $response | jq '[.[] | select(.author.id != .noteable_author_id and .author.id != '$EXCLUDED_USER_ID' and .system == false)] | length')

# 結果を出力
echo "コメント数: $comment_count"





#!/bin/bash

# 設定
gitlab_url="https://gitlab.example.com" # GitLab URL
gitlab_token="YOUR_ACCESS_TOKEN" # 個人アクセストークン
mr_id=123 # マージリクエストID
user_id_to_exclude=12 # 除外するユーザーID

# ヘッダー
headers=(
  "PRIVATE-TOKEN: $gitlab_token"
)

# APIエンドポイント
endpoint="$gitlab_url/api/v4/merge_requests/$mr_id/notes"

# コメント取得
response=$(curl -sSL -H "${headers[@]}" "$endpoint")

# JSON解析
notes_count=$(
  echo "$response" | jq -r '.[] | select(
    .author_id != '$user_id_to_exclude'
    and .system != true
    and .author_username != "gitlab"
  ) | length'
)

# 出力
echo "$notes_count"



echo "$merge_requests" | jq -r '.[] | "\(.id) \(.author.id)"' | while read -r mr_id author_id; do
    # 各MRに対してコメント数を取得
    comments=$(curl -s "https://gitlab.com/api/v4/projects/$project_id/merge_requests/$mr_id/notes?private_token=$PRIVATE_TOKEN")
    comments_count=$(echo "$comments" | jq '[.[] | select(.system == false)] | length')

    # MR情報とコメント数を組み合わせてSQLファイルに書き込む
    echo "$merge_requests" | jq -r --arg mr_id "$mr_id" --arg author_id "$author_id" --arg project_name "$project_name" --arg namespace_path "$namespace_path" --arg comments_count "$comments_count" \
        '.[] | select(.id == ($mr_id | tonumber)) | "(\(.id), '\''\($namespace_path)'\'', '\''\($project_name)'\'', '\''\(.title | gsub("'"'"'; "'"'"''"'"'"))'\'', '\''\(.created_at)'\'', '\''\(.state)'\'', '\''\($author_id)'\'', '\''\(.merged_at // "NULL")'\'', '\''\(.source_branch)'\'', '\''\(.web_url)'\'', $comments_count)," >> $SQL_FILE
done

