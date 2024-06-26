def convert_market_name(full_name):
    # 証券取引所の辞書を作成
    market_dict = {
        '東京証券取引所': '東証',
        '札幌証券取引所': '札証',
        '名古屋証券取引所': '名証',
        '福岡証券取引所': '福証',
        'ジャスダック': 'JASDAQ',
        '東証': '東証',
        '札証': '札証',
        '名証': '名証',
        '福証': '福証'
    }
    
    # 証券取引所ごとの市場区分の辞書を作成
    market_segments = {
        '東証': ['プライム', 'スタンダード', 'グロース'],
        '札証': ['アンビシャス', '本則'],
        '名証': ['プレミア', 'メイン', 'ネクスト'],
        '福証': ['Q-Board', '本則'],
        'JASDAQ': ['グロース']
    }
    
    for key in market_dict:
        if full_name.startswith(key):
            exchange_short = market_dict[key]
            for segment in market_segments.get(exchange_short, []):
                if segment in full_name:
                    return f"{exchange_short}{segment}"
            return exchange_short
    
    return full_name

# テスト
test_cases = [
    "東京証券取引所プライム",
    "東京証券取引所スタンダード",
    "東京証券取引所グロース",
    "名古屋証券取引所プレミア",
    "名古屋証券取引所メイン",
    "名古屋証券取引所ネクスト",
    "札幌証券取引所アンビシャス",
    "札幌証券取引所本則",
    "福岡証券取引所Q-Board",
    "福岡証券取引所本則",
    "東証プライム",
    "東証スタンダード",
    "東証グロース",
    "名証プレミア",
    "名証メイン",
    "名証ネクスト",
    "札証アンビシャス",
    "札証本則",
    "福証Q-Board",
    "福証本則",
    "JASDAQグロース",
    "東京証券取引所プレミア"  # 存在しない区分
]

for test in test_cases:
    print(convert_market_name(test))



for key in market_dict:
        if key in full_name:
            exchange_short = market_dict[key]
            for segment in market_segments.get(exchange_short, []):
                if segment in full_name:
                    return f"{exchange_short}{segment}"
            return exchange_short

    return full_name


UPDATE テーブル２ t2
SET t2.カラムF = t1.カラムB,
    t2.カラムG = t1.カラムC
FROM テーブル１ t1
WHERE t1.カラムA = t2.カラムE;



= REPLACE(t1.カラムB, '株式会社', ''),

