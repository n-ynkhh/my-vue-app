import csv
import json

# JSONファイルを読み込む
with open('your_data.json') as json_file:
    data = json.load(json_file)

# CSVファイルに書き出す
with open('your_data.csv', 'w', newline='') as csv_file:
    writer = csv.writer(csv_file)
    # ヘッダー（キー名）を書き出す
    writer.writerow(data[0].keys())
    # 各レコード（値）を書き出す
    for item in data:
        writer.writerow(item.values())
