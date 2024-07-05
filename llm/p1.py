import requests
import fitz  # PyMuPDF
import openai
import os

# Azure OpenAI Serviceの設定
openai.api_type = "azure"
openai.api_base = "https://YOUR_RESOURCE_NAME.openai.azure.com/"
openai.api_version = "v1"
openai.api_key = 'YOUR_AZURE_OPENAI_API_KEY'

def download_pdf(url, save_path):
    response = requests.get(url)
    response.raise_for_status()  # エラーがあれば例外を発生させる
    with open(save_path, 'wb') as f:
        f.write(response.content)

def extract_text_from_pdf(pdf_path):
    text = ""
    with fitz.open(pdf_path) as doc:
        for page in doc:
            text += page.get_text()
    return text

def split_text(text, max_length):
    """長いテキストをmax_length以下の部分に分割する"""
    return [text[i:i+max_length] for i in range(0, len(text), max_length)]

def ask_openai(question, context):
    response = openai.Completion.create(
        engine="YOUR_MODEL_NAME",  # デプロイしたモデルの名前
        prompt=f"Context: {context}\n\nQuestion: {question}\n\nAnswer:",
        max_tokens=150,
        temperature=0.7,
    )
    return response.choices[0].text.strip()

def main():
    pdf_url = 'https://example.com/path/to/your/pdf/document.pdf'
    pdf_path = 'downloaded_document.pdf'
    
    # PDFをダウンロード
    download_pdf(pdf_url, pdf_path)
    
    # テキストを抽出
    context = extract_text_from_pdf(pdf_path)
    
    # 一時的なファイルを削除
    os.remove(pdf_path)
    
    # コンテキストを分割する
    max_context_length = 2000  # 適切な長さに調整
    context_parts = split_text(context, max_context_length)
    
    questions = [
        "What is the main topic of the document?",
        "Who is the author of the document?",
        "Summarize the key points of the document.",
    ]
    
    for question in questions:
        answers = []
        for part in context_parts:
            answer = ask_openai(question, part)
            answers.append(answer)
        combined_answer = " ".join(answers)
        print(f"Q: {question}\nA: {combined_answer}\n")

if __name__ == "__main__":
    main()
