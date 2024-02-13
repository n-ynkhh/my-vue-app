START_DATE=$(date -u -d "$YEAR_MONTH-01" '+%Y-%m-%dT%H:%M:%SZ')

# 指定された年月の最終日の23:59を日本時間で計算し、UTCに変換
END_DATE=$(date -u -d "$YEAR_MONTH-01 +1 month -1 day 9 hours" '+%Y-%m-%dT%H:%M:%SZ')
