import requests
import datetime

def fetch_document_ids(start_date, end_date, api_key, edinet_codes):
    url = "https://disclosure.edinet-fsa.go.jp/api/v2/documents.json"
    doc_ids = []
    date_range = pd.date_range(start_date, end_date)

    for date in date_range:
        params = {
            'date': date.strftime('%Y-%m-%d'),
            'type': 2,  # 有価証券報告書
            "Subscription-Key": api_key
        }
        response = requests.get(url, params=params)
        data = response.json()
        for result in data.get('results', []):
            if result['ordinanceCode'] == '010' and result['formCode'] == '030000' and result['edinetCode'] in edinet_codes:
                doc_ids.append(result['docID'])

    return doc_ids

if __name__ == "__main__":
    start_date = '2024-01-01'
    end_date = '2024-01-31'
    api_key = 'your_api_key'

    # Snowflakeから上場企業のEdinetコードリストを取得
    edinet_codes = fetch_edinet_codes_from_snowflake(snowflake_config)
    
    doc_ids = fetch_document_ids(start_date, end_date, api_key, edinet_codes)
    print(doc_ids)
