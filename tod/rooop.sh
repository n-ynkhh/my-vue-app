  while : ; do
    BRANCHES_JSON=$(curl --silent --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/repository/branches?per_page=$PER_PAGE&page=$PAGE")
    if [[ "x$BRANCHES_JSON" == "x[]" ]]; then break; fi
    echo "$BRANCHES_JSON" | jq -r '.[] | .name'
    ((PAGE++))
  done



#!/bin/bash

# 変数の設定
GITLAB_HOST="https://gitlab.example.com" # GitLabのホスト名
PRIVATE_TOKEN="<あなたのアクセストークン>" # あなたのGitLabアクセストークン
PROJECT_ID="<プロジェクトID>" # プロジェクトID

# ブランチを格納する変数
BRANCHES=""

# ページネーションの設定
PAGE=1
PER_PAGE=100

# APIからブランチのリストを取得してループ処理
while : ; do
  # GitLab APIを使用してブランチのリストを取得
  RESPONSE=$(curl --silent --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/repository/branches?per_page=$PER_PAGE&page=$PAGE")

  # レスポンスが空かどうかチェック
  if [ "x$RESPONSE" == "x[]" ] || [ "x$RESPONSE" == "x" ]; then
    break # 空の場合、ループを終了
  fi

  # ブランチ名のみを抽出してBRANCHES変数に追加
  BRANCHES+="$(echo "$RESPONSE" | jq -r '.[].name') "
  
  ((PAGE++)) # 次のページへ
done

# 末尾の空白を削除
BRANCHES=$(echo "$BRANCHES" | sed 's/ $//')

# 結果の出力
echo "All branches:"
echo "$BRANCHES"
