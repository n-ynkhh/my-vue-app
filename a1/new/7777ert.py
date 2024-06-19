# 東京都の区のリスト
tokyo_wards = [
    "千代田区", "中央区", "港区", "新宿区", "文京区", "台東区", "墨田区", "江東区",
    "品川区", "目黒区", "大田区", "世田谷区", "渋谷区", "中野区", "杉並区", "豊島区",
    "北区", "荒川区", "板橋区", "練馬区", "足立区", "葛飾区", "江戸川区"
]

# 県庁所在地と県名が異なるリスト
special_cases = {
    "横浜市": "神奈川県",
    "神戸市": "兵庫県",
    "京都市": "京都府",
    "大阪市": "大阪府",
    # 他のケースも同様に追加
}

# 都道府県リスト
prefectures = [
    "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
    "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
    "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県",
    "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県",
    "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県",
    "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県",
    "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
]

def find_prefecture(address):
    # 東京都の区で判定
    for ward in tokyo_wards:
        if ward in address:
            return "東京都"
    
    # 県庁所在地と県名が異なるケースで判定
    for city, prefecture in special_cases.items():
        if city in address:
            return prefecture
    
    # 住所の先頭に都道府県名が含まれる場合
    for prefecture in prefectures:
        if address.startswith(prefecture):
            return prefecture
    
    # 住所が「○○市」から始まる場合
    for prefecture in prefectures:
        city_name = prefecture.replace("県", "市").replace("府", "市").replace("東京都", "東京市")
        if address.startswith(city_name):
            return prefecture
    
    # 該当する市区町村が見つからない場合
    return "該当なし"

# テスト用の住所データ
addresses = [
    "横浜市中区",
    "山口市吉敷",
    "東京都新宿区",
    "千葉市中央区",
    "山形県新庄市",
    "広島県広島市中区",
    "不明な住所データ"
]

# 住所データから都道府県を判定
results = {address: find_prefecture(address) for address in addresses}

for address, prefecture in results.items():
    print(f"住所: {address}, 都道府県: {prefecture}")
