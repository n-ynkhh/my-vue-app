import os
import openai
import fitz  # PyMuPDF
import pandas as pd

# Azure OpenAI Serviceの設定
openai.api_key = 'YOUR_AZURE_OPENAI_API_KEY'
openai.api_base = 'YOUR_AZURE_OPENAI_ENDPOINT'  # 例: 'https://<your-resource-name>.openai.azure.com/'
openai.api_type = 'azure'
openai.api_version = '2023-05-15'  # 使用するAPIバージョンを指定

model_engine = 'text-davinci-003'  # 例：text-davinci-003

def extract_text_from_pdf(pdf_path):
    # PDFからテキストを抽出
    text = ""
    document = fitz.open(pdf_path)
    for page_num in range(len(document)):
        page = document.load_page(page_num)
        text += page.get_text()
    return text

def query_openai(prompt):
    response = openai.Completion.create(
        engine=model_engine,
        prompt=prompt,
        max_tokens=1500,
        temperature=0.5
    )
    return response

def split_text(text, max_length=2048):
    # テキストをmax_length未満のチャンクに分割
    chunks = []
    while len(text) > max_length:
        split_pos = text.rfind('。', 0, max_length)
        if split_pos == -1 or split_pos == 0:
            split_pos = max_length
        chunks.append(text[:split_pos].strip())
        text = text[split_pos:].strip()
    chunks.append(text.strip())
    return chunks

def extract_info_from_text(text, queries):
    # テキストを適切な長さに分割
    chunks = split_text(text)
    all_results = ""
    
    # 各チャンクに対してAzure OpenAIに問い合わせ
    for chunk in chunks:
        combined_query = "以下のテキストから次の情報を抽出してください：\n\n" + chunk + "\n\n"
        response = query_openai(combined_query)
        all_results += response['choices'][0]['text'].strip()
    
    # クエリごとに情報を抽出
    results = {}
    for query in queries:
        start_index = all_results.find(query)
        if start_index != -1:
            end_index = all_results.find("\n", start_index)
            results[query] = all_results[start_index + len(query):end_index].strip()
        else:
            results[query] = "Not found"
    
    return results

def process_pdf(pdf_path):
    text = extract_text_from_pdf(pdf_path)
    queries = [
        "単体決算_女性管理職比率",
        "連結決算_女性管理職比率",
        "単体決算_従業員1人当たりの平均研修時間",
        "連結決算_従業員1人当たりの平均研修時間"
    ]
    return extract_info_from_text(text, queries)

def process_directory(directory_path):
    data = []
    for filename in os.listdir(directory_path):
        if filename.endswith('.pdf'):
            pdf_path = os.path.join(directory_path, filename)
            extracted_data = process_pdf(pdf_path)
            # PDFごとに単体・連結のデータを分けてリストに追加
            for key, value in extracted_data.items():
                if "単体決算" in key:
                    data.append({
                        "ファイル名": filename,
                        "タイプ": "単体",
                        "項目": key,
                        "値": value
                    })
                elif "連結決算" in key:
                    data.append({
                        "ファイル名": filename,
                        "タイプ": "連結",
                        "項目": key,
                        "値": value
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
