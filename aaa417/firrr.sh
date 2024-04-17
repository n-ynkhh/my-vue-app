#!/bin/bash

# このスクリプトは、引数によって異なる日付の範囲を処理します。
# 使用方法:
# 1. 引数無し: 昨日の0時0分0秒から23時59分59秒までを処理します。
# 2. 引数が1つ (YYYY-MM-DD形式の日付): 指定日の0時0分0秒からその日の23時59分59秒までを処理します。
# 3. 引数が2つ (それぞれYYYY-MM-DD形式の日付): 第一引数の日の0時0分0秒から第二引数の日の23時59分59秒までを処理します。
# 注意: 引数の日付が不正な形式であったり、第一引数の日付が第二引数より未来の場合はエラーを返します。

# 引数の日付形式を YYYY-MM-DD と想定
date_format="%Y-%m-%d"

# 引数がない場合
if [ $# -eq 0 ]; then
    # 昨日の日付を設定
    date_a=$(date -d 'yesterday 00:00:00' +"$date_format %T")
    date_b=$(date -d 'yesterday 23:59:59' +"$date_format %T")
elif [ $# -eq 1 ]; then
    # 引数の形式をチェック
    if date -d "$1" +"$date_format" &> /dev/null; then
        # 日付1の0時と23時59分59秒をセット
        date_a=$(date -d "$1 00:00:00" +"$date_format %T")
        date_b=$(date -d "$1 23:59:59" +"$date_format %T")
    else
        echo "エラー: 日付の形式が正しくありません。"
        exit 1
    fi
elif [ $# -eq 2 ]; then
    # 二つの日付の形式をチェック
    if date -d "$1" +"$date_format" &> /dev/null && date -d "$2" +"$date_format" &> /dev/null; then
        # 日付をエポック秒で比較
        if [ $(date -d "$1" +%s) -gt $(date -d "$2" +%s) ]; then
            echo "エラー: 日付1が日付2よりも先の日付です。"
            exit 1
        fi
        # 日付1の0時と日付2の23時59分59秒をセット
        date_a=$(date -d "$1 00:00:00" +"$date_format %T")
        date_b=$(date -d "$2 23:59:59" +"$date_format %T")
    else
        echo "エラー: 日付の形式が正しくありません。"
        exit 1
    fi
else
    echo "エラー: 引数の数が多すぎます。"
    exit 1
fi

echo "DATE-A: $date_a"
echo "DATE-B: $date_b"
