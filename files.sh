#!/bin/bash

# 以前のスクリプトの設定...

# SQLファイルのパスを設定
SQL_FILE="merge_requests.sql"

# SQLファイルを初期化
echo "-- Merge requests data into Snowflake" > $SQL_FILE

# 以前のスクリプトの処理...

        # SQLコマンドをファイルに追加（例えば）
        echo "$merge_requests" | jq -r --arg project_name "$project_name" --arg namespace_path "$namespace_path" \
            '.[] | "MERGE INTO your_merge_requests_table USING (SELECT ...);"' >> $SQL_FILE

# 以前のスクリプトの処理の終了...

# SnowSQLでSQLファイルを実行
# 注意: このコマンドを実行する前に、YOUR_USERNAME、YOUR_PASSWORD、YOUR_ACCOUNT等を適切な値に置き換えてください。
snowsql --username YOUR_USERNAME --password YOUR_PASSWORD --account YOUR_ACCOUNT -f $SQL_FILE
