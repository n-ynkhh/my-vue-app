#!/bin/bash

TOKEN="your_private_token"
OUTPUT_FILE="commits.sql"
SINCE_DATE=""
UNTIL_DATE=""
FIRST_RECORD=true

# 引数から取得対象の年月をセット、指定がなければ前月を対象とする
if [ -n "$1" ]; then
    YEAR=$(echo $1 | cut -d '-' -f 1)
    MONTH=$(echo $1 | cut -d '-' -f 2)
    SINCE_DATE=$(date -d "$YEAR-$MONTH-1" '+%Y-%m-%dT%H:%M:%SZ')
    UNTIL_DATE=$(date -d "$YEAR-$MONTH-1 next month -1 second" '+%Y-%m-%dT%H:%M:%SZ')
else
    SINCE_DATE=$(date -d "last month" '+%Y-%m-01T00:00:00Z')
    UNTIL_DATE=$(date -d "$(date +%Y-%m-01) -1 second" '+%Y-%m-%dT%H:%M:%SZ')
fi

# 出力ファイルの初期化
echo -n "" > $OUTPUT_FILE
echo "INSERT INTO commits (group_name, project_name, author_name, commit_date, commit_hash, commit_message, added_lines, deleted_lines, is_merge_commit) VALUES" >> $OUTPUT_FILE

PAGE=1
while true; do
    PROJECTS=$(curl -s --header "Private-Token: $TOKEN" "https://gitlab.example.com/api/v4/projects?per_page=100&page=$PAGE&private_token=$TOKEN")
    if [ -z "$PROJECTS" ] || [ "$PROJECTS" = "[]" ]; then
        break
    fi

    echo "$PROJECTS" | jq -c '.[] | select(.forked_from_project == null)' | while read i; do
        PROJECT_ID=$(echo $i | jq -r '.id')
        PROJECT_NAME=$(echo $i | jq -r '.path_with_namespace' | sed 's/\//_/g')
        GROUP_NAME=$(echo $i | jq -r '.namespace.name')

        # プロジェクトの全ブランチを取得
        BRANCHES=$(curl -s --header "Private-Token: $TOKEN" "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/repository/branches?per_page=100&private_token=$TOKEN")
        echo "$BRANCHES" | jq -r '.[].name' | while read BRANCH; do

            # ブランチの全コミットを取得
            COMMITS=$(curl -s --header "Private-Token: $TOKEN" "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/repository/commits?ref_name=$BRANCH&since=$SINCE_DATE&until=$UNTIL_DATE&per_page=100&private_token=$TOKEN")
            echo "$COMMITS" | jq -c '.[]' | while read j; do
                COMMIT_HASH=$(echo $j | jq -r '.id')
                AUTHOR_NAME=$(echo $j | jq -r '.author_name')
                COMMIT_DATE=$(echo $j | jq -r '.committed_date')
                COMMIT_MESSAGE=$(echo $j | jq -r '.title' | sed 's/"/\\"/g')
                IS_MERGE_COMMIT=$(echo $j | jq -r '.parent_ids | length > 1')

                COMMIT_DETAIL=$(curl -s --header "Private-Token: $TOKEN" "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/repository/commits/$COMMIT_HASH?private_token=$TOKEN")
                ADDED_LINES=$(echo $COMMIT_DETAIL | jq '.stats.additions')
                DELETED_LINES=$(echo $COMMIT_DETAIL | jq '.stats.deletions')

                # 最初のレコード以外の前にカンマを追加
                if $FIRST_RECORD; then
                    FIRST_RECORD=false
                else
                    echo "," >> $OUTPUT_FILE
                fi
                echo "('$GROUP_NAME', '$PROJECT_NAME', '$AUTHOR_NAME', '$COMMIT_DATE', '$COMMIT_HASH', \"$COMMIT_MESSAGE\", $ADDED_LINES, $DELETED_LINES, $IS_MERGE_COMMIT)" >> $OUTPUT_FILE
            done
        done
    done

    let PAGE+=1
done

# 最後にセミコロンを追加
echo ";" >> $OUTPUT_FILE





# Construct the SQL insert statement
      INSERT_STMT="('$GROUP_NAME', '$PROJECT_NAME', '$AUTHOR_NAME', '$COMMIT_DATE', '$COMMIT_HASH', '$COMMIT_MESSAGE', $ADDED_LINES, $DELETED_LINES, $IS_MERGE_COMMIT),"

      # Append the insert statement to the output file
      echo -n "$INSERT_STMT" >> output.sql
    done

    # Replace the last comma with a semicolon at the end of each branch's commits
    sed -i '$ s/,$/;/' output.sql
