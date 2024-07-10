import os
import requests
import PyPDF2
import json
import pandas as pd

# Azure OpenAI Serviceの設定
API_KEY = 'YOUR_AZURE_OPENAI_API_KEY'
ENDPOINT = 'YOUR_AZURE_OPENAI_ENDPOINT'
MODEL = 'text-davinci-003'  # 例：text-davinci-003

def extract_text_from_pdf(pdf_path):
    # PDFからテキストを抽出
    text = ""
    with open(pdf_path, 'rb') as file:
        reader = PyPDF2.PdfFileReader(file)
        for page_num in range(reader.numPages):
            text += reader.getPage(page_num).extract_text()
    return text

def query_openai(prompt):
    headers = {
        'Content-Type': 'application/json',
        'api-key': API_KEY,
    }
    payload = {
        'prompt': prompt,
        'max_tokens': 1500,
        'temperature': 0.5,
    }
    response = requests.post(f"{ENDPOINT}/openai/deployments/{MODEL}/completions", headers=headers, json=payload)
    response.raise_for_status()
    return response.json()

def extract_info_from_text(text, queries):
    combined_query = "以下のテキストから次の情報を抽出してください：\n\n" + text + "\n\n"
    for query in queries:
        combined_query += f"{query}\n"

    response = query_openai(combined_query)
    extracted_text = response['choices'][0]['text'].strip()

    results = {}
    for query in queries:
        start_index = extracted_text.find(query)
        if start_index != -1:
            end_index = extracted_text.find("\n", start_index)
            results[query] = extracted_text[start_index + len(query):end_index].strip()
        else:
            results[query] = "Not found"
    return results

def process_pdf(pdf_path):
    text = extract_text_from_pdf(pdf_path)
    queries = [
        "女性管理職比率",
        "従業員1人当たりの平均研修時間",
        "単体の女性管理職比率",
        "連結の女性管理職比率",
        "単体の従業員1人当たりの平均研修時間",
        "連結の従業員1人当たりの平均研修時間"
    ]
    return extract_info_from_text(text, queries)

def process_directory(directory_path):
    data = []
    for filename in os.listdir(directory_path):
        if filename.endswith('.pdf'):
            pdf_path = os.path.join(directory_path, filename)
            extracted_data = process_pdf(pdf_path)
            # PDFごとに単体・連結のデータを分けてリストに追加
            data.append({
                "ファイル名": filename,
                "タイプ": "単体",
                "女性管理職比率": extracted_data.get("単体の女性管理職比率"),
                "従業員1人当たりの平均研修時間": extracted_data.get("単体の従業員1人当たりの平均研修時間")
            })
            data.append({
                "ファイル名": filename,
                "タイプ": "連結",
                "女性管理職比率": extracted_data.get("連結の女性管理職比率"),
                "従業員1人当たりの平均研修時間": extracted_data.get("連結の従業員1人当たりの平均研修時間")
            })
    return data

def save_to_csv(data, csv_path):
    df = pd.DataFrame(data)
    df.to_csv(csv_path, index=False, encoding='utf-8-sig')

if __name__ == "__main__":
    directory_path = 'path_to_your_directory'  # 読み込むPDFファイルがあるディレクトリのパス
    csv_path = 'output.csv'  # 保存するCSVファイルのパス
    extracted_data = process_directory(directory_path)
    save_to_csv(extracted_data, csv_path)
    print(f"Extracted data saved to {csv_path}")
