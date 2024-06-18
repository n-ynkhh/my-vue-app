import requests
import pandas as pd
import argparse

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

def fetch_edinet_codes_from_snowflake(snowflake_config):
    conn = snowflake.connector.connect(
        user=snowflake_config['user'],
        password=snowflake_config['password'],
        account=snowflake_config['account'],
        warehouse=snowflake_config['warehouse'],
        database=snowflake_config['database'],
        schema=snowflake_config['schema']
    )
    
    query = "SELECT edinet_code FROM company_master WHERE listing_status = '上場'"
    cursor = conn.cursor()
    cursor.execute(query)
    rows = cursor.fetchall()
    edinet_codes = [row[0] for row in rows]

    cursor.close()
    conn.close()

    return edinet_codes

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Fetch EDINET document IDs.')
    parser.add_argument('start_date', type=str, help='The start date in YYYY-MM-DD format')
    parser.add_argument('end_date', type=str, help='The end date in YYYY-MM-DD format')
    parser.add_argument('api_key', type=str, help='The EDINET API key')
    args = parser.parse_args()

    snowflake_config = {
        'user': 'your_user',
        'password': 'your_password',
        'account': 'your_account',
        'warehouse': 'your_warehouse',
        'database': 'your_database',
        'schema': 'your_schema'
    }

    edinet_codes = fetch_edinet_codes_from_snowflake(snowflake_config)
    doc_ids = fetch_document_ids(args.start_date, args.end_date, args.api_key, edinet_codes)
    print(doc_ids)
