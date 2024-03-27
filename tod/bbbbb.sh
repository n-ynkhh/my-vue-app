ENCODED_BRANCH_NAME=$(jq -nr --arg bn "$BRANCH_NAME" '$bn|@uri')
