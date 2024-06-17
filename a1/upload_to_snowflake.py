import snowflake.connector
import os

def upload_csv_to_snowflake(file_path, table_name, snowflake_config):
    conn = snowflake.connector.connect(
        user=snowflake_config['user'],
        password=snowflake_config['password'],
        account=snowflake_config['account'],
        warehouse=snowflake_config['warehouse'],
        database=snowflake_config['database'],
        schema=snowflake_config['schema']
    )
    
    cursor = conn.cursor()
    cursor.execute(f"TRUNCATE TABLE {table_name}")
    success, nchunks, nrows, _ = cursor.write_pandas(pd.read_csv(file_path), table_name)

    cursor.close()
    conn.close()

    return success, nrows

def combine_and_insert_data(snowflake_config):
    conn = snowflake.connector.connect(
        user=snowflake_config['user'],
        password=snowflake_config['password'],
        account=snowflake_config['account'],
        warehouse=snowflake_config['warehouse'],
        database=snowflake_config['database'],
        schema=snowflake_config['schema']
    )
    
    cursor = conn.cursor()
    query = """
    INSERT INTO final_table (columns...)
    SELECT a.columns..., b.columns...
    FROM uploaded_csv_table a
    JOIN company_master b
    ON a.edinet_code = b.edinet_code;
    """
    cursor.execute(query)
    conn.commit()

    cursor.close()
    conn.close()

if __name__ == "__main__":
    csv_files_dir = 'path/to/csv_files'
    table_name = 'uploaded_csv_table'
    snowflake_config = {
        'user': 'your_user',
        'password': 'your_password',
        'account': 'your_account',
        'warehouse': 'your_warehouse',
        'database': 'your_database',
        'schema': 'your_schema'
    }

    # CSVファイルのアップロード
    for csv_file in os.listdir(csv_files_dir):
        file_path = os.path.join(csv_files_dir, csv_file)
        upload_csv_to_snowflake(file_path, table_name, snowflake_config)
    
    # データの結合とインサート
    combine_and_insert_data(snowflake_config)
