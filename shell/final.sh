# コミットデータが存在し、かつidフィールドが含まれる項目が1つ以上あるかを確認
if echo "$COMMITS" | jq -e '.[] | select(.id != null)' >/dev/null; then
    echo "$COMMITS" | jq -c '.[] | select(.id != null)' | while read j; do
        COMMIT_HASH=$(echo $j | jq -r '.id')
        AUTHOR_NAME=$(echo $j | jq -r '.author_name')
        COMMIT_DATE=$(echo $j | jq -r '.committed_date')
        COMMIT_MESSAGE=$(echo $j | jq -r '.title' | sed -e "s/'/''/g" -e 's/\"/\\"/g')
        IS_MERGE_COMMIT=$(echo $j | jq -r '.parent_ids | length > 1')

        # Fetch commit diff to get added and deleted lines
        DIFF_STATS=$(curl -s "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/repository/commits/$COMMIT_HASH/diff_stats?private_token=$TOKEN")
        ADDED_LINES=$(echo "$DIFF_STATS" | jq '[.[] | .additions] | add')
        DELETED_LINES=$(echo "$DIFF_STATS" | jq '[.[] | .deletions] | add')

        # Construct the SQL insert statement with a newline at the end
        INSERT_STMT="('$GROUP_NAME', '$PROJECT_NAME', '$AUTHOR_NAME', '$COMMIT_DATE', '$COMMIT_HASH', '$COMMIT_MESSAGE', $ADDED_LINES, $DELETED_LINES, $IS_MERGE_COMMIT),\n"

        # Append the insert statement to the output file
        echo -n "$INSERT_STMT" >> output.sql
    done
fi



job_b:
  script:
    - echo "Executing job_b"
  rules:
    - if: '($CI_PIPELINE_SOURCE == "web" || $CI_PIPELINE_SOURCE == "schedule") && $JOB_NAME == "job_b"'



# 出力ファイルの初期化
echo "INSERT INTO commits (group_name, project_name, author_name, commit_date, commit_hash, commit_message, added_lines, deleted_lines, is_merge_commit) VALUES" > output.sql

# GitLab APIからプロジェクトのリストを取得
PROJECTS=$(curl -s "https://gitlab.example.com/api/v4/projects?private_token=$TOKEN&per_page=100")

# 重複するコミットを追跡するための変数
declare -A COMMIT_TRACKER

echo "$PROJECTS" | jq -c '.[]' | while read i; do
    PROJECT_ID=$(echo $i | jq -r '.id')
    PROJECT_NAME=$(echo $i | jq -r '.path_with_namespace')
    DEFAULT_BRANCH=$(echo $i | jq -r '.default_branch')

    # 対象となるブランチリストを作成

    BRANCHES=("$DEFAULT_BRANCH")  # デフォルトでデフォルトブランチを含める
    # デフォルトブランチが 'master' または 'main' ではない場合、それらを追加
    [[ "$DEFAULT_BRANCH" != "master" ]] && BRANCHES+=("master")
    [[ "$DEFAULT_BRANCH" != "main" ]] && BRANCHES+=("main")
    for BRANCH in "${BRANCHES[@]}"; do
        # ブランチが存在するかチェック
        BRANCH_EXISTS=$(curl -s "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/repository/branches/$BRANCH?private_token=$TOKEN")
        if [[ $(echo $BRANCH_EXISTS | jq -r '.name') == "$BRANCH" ]]; then
            # コミット情報を取得
            COMMITS=$(curl -s "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/repository/commits?private_token=$TOKEN&ref_name=$BRANCH&per_page=100")
            echo "$COMMITS" | jq -c '.[]' | while read j; do
                COMMIT_HASH=$(echo $j | jq -r '.id')

                # 重複するコミットをスキップ
                if [[ -z "${COMMIT_TRACKER[$COMMIT_HASH]}" ]]; then
                    COMMIT_TRACKER[$COMMIT_HASH]=1
                    AUTHOR_NAME=$(echo $j | jq -r '.author_name')
                    COMMIT_DATE=$(echo $j | jq -r '.committed_date')
                    COMMIT_MESSAGE=$(echo $j | jq -r '.title' | sed -e "s/'/''/g" -e 's/\"/\\"/g')
                    IS_MERGE_COMMIT=$(echo $j | jq -r '.parent_ids | length > 1')

                    # 追加行数と削除行数を取得するためのAPI呼び出しは省略

                    # SQL文を構築してファイルに追記
                    INSERT_STMT="('$PROJECT_NAME', '$AUTHOR_NAME', '$COMMIT_DATE', '$COMMIT_HASH', '$COMMIT_MESSAGE', $ADDED_LINES, $DELETED_LINES, $IS_MERGE_COMMIT),\n"
                    echo -n "$INSERT_STMT" >> output.sql
                fi
            done
        fi
    done
done

# 最後のカンマを削除してクエリを完成させる
sed -i '$ s/,$/;/' output.sql
