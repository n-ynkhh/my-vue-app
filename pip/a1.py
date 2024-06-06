from bs4 import BeautifulSoup
import pandas as pd

# XBRLファイルの読み込み
with open('example.xbrl', 'r', encoding='utf-8') as file:
    soup = BeautifulSoup(file, 'xml')

# データの抽出
columns = []
values = []

# 各<tr>タグ内の<td>タグを取得
for row in soup.find_all('tr'):
    column_elements = row.find_all('td')
    if len(column_elements) == 2:
        columns.append(column_elements[0].text.strip())
        values.append(column_elements[1].text.strip())

# データフレームに変換
df = pd.DataFrame({'Column': columns, 'Value': values})

# データの表示
print(df.head())

# CSVに保存
df.to_csv('output.csv', index=False)
