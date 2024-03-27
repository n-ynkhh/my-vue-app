ENCODED_BRANCH_NAME=$(jq -nr --arg bn "$BRANCH_NAME" '$bn|@uri')

AAA="テスト_test"
curl -G -v api_url/data --data-urlencode "name=$AAA"
