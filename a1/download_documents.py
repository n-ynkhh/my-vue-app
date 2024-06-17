import requests
import zipfile
import io
import os

def download_and_extract_zip(doc_id, api_key, save_dir):
    url = f"https://disclosure.edinet-fsa.go.jp/api/v2/documents/{doc_id}"
    params = {"type": 5, "Subscription-Key": api_key}
    response = requests.get(url, params=params)
    
    with zipfile.ZipFile(io.BytesIO(response.content)) as z:
        for file in z.namelist():
            if "-asr-" in file and file.endswith(".csv"):
                z.extract(file, path=save_dir)
                print(f"Extracted {file} to {save_dir}")

if __name__ == "__main__":
    doc_ids = ['doc_id1', 'doc_id2']  # 書類IDのリスト
    api_key = 'your_api_key'
    save_dir = 'path/to/save_dir'

    for doc_id in doc_ids:
        download_and_extract_zip(doc_id, api_key, save_dir)
