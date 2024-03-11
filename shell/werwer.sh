#!/bin/bash

# 元の日時文字列
original_datetime="2024-03-08T09:12:17.000+000"

# UTCの日時をJSTに変換（+9時間）
jst_datetime=$(date -u -d "$original_datetime UTC +9 hours" +"%Y-%m-%d %H:%M:%S.%3N")

echo "JST datetime: $jst_datetime"




#!/bin/bash

# UTCの日時
utc_date="2024-03-08T09:12:17.000+0000"

# UTC日時を日本時間に変換 (JSTはUTC+9)
jst_date=$(date -u -d "$utc_date" +"%Y-%m-%d %H:%M:%S.%3N" -d '+9 hours')

# 結果を表示
echo "JST Date: $jst_date"
