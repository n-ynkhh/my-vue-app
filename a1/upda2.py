import pandas as pd
import snowflake.connector

def update_company_master(file_path, snowflake_config):
    # 企業一覧マスタファイルを読み込み
    try:
        df = pd.read_csv(file_path, encoding='shift-jis')
    except UnicodeDecodeError:
        df = pd.read_csv(file_path, encoding='utf-8')

    # Snowflakeに接続
    conn = snowflake.connector.connect(
        user=snowflake_config['user'],
        password=snowflake_config['password'],
        account=snowflake_config['account'],
        warehouse=snowflake_config['warehouse'],
        database=snowflake_config['database'],
        schema=snowflake_config['schema']
    )
    
    cursor = conn.cursor()

    # テーブルをクリアしてデータをロード
    cursor.execute("TRUNCATE TABLE company_master")
    success, nchunks, nrows, _ = cursor.write_pandas(df, 'COMPANY_MASTER')

    cursor.close()
    conn.close()

    return success, nrows

if __name__ == "__main__":
    # 手動で取得した企業一覧マスタファイルのパス
    file_path = 'path/to/company_master.csv'
    # Snowflakeの接続情報
    snowflake_config = {
        'user': 'your_user',
        'password': 'your_password',
        'account': 'your_account',
        'warehouse': 'your_warehouse',
        'database': 'your_database',
        'schema': 'your_schema'
    }
    
    success, nrows = update_company_master(file_path, snowflake_config)
    print(f"Update Success: {success}, Rows Updated: {nrows}")
