from bs4 import BeautifulSoup
import pandas as pd
import html

# XBRLファイルの読み込み
with open('example.xbrl', 'r', encoding='utf-8') as file:
    content = file.read()

# エンティティ参照のデコード
decoded_content = html.unescape(content)

# BeautifulSoupでデコード後の文書をパース
soup = BeautifulSoup(decoded_content, 'xml')

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


from bs4 import BeautifulSoup
import pandas as pd
import html

# XBRLファイルの読み込み
with open('example.xbrl', 'r', encoding='utf-8') as file:
    content = file.read()

# エンティティ参照のデコード
decoded_content = html.unescape(content)

# BeautifulSoupでデコード後の文書をパース
soup = BeautifulSoup(decoded_content, 'xml')

# データの抽出
columns = []
values = []

# 各<tr>タグ内の<td>タグを取得
for row in soup.find_all('tr'):
    column_elements = row.find_all('td')
    if len(column_elements) == 2:
        # <td>内のすべてのテキストを結合して抽出
        columns.append(column_elements[0].get_text(strip=True))
        values.append(column_elements[1].get_text(strip=True))

# データフレームに変換
df = pd.DataFrame({'Column': columns, 'Value': values})

# データの表示
print(df.head())

# CSVに保存
df.to_csv('output.csv', index=False)
