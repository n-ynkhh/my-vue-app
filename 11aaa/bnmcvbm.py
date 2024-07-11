import openai

# OpenAI APIキー
openai.api_key = 'YOUR_API_KEY'

# 文字列化したPDFデータ
pdf_content = "Your stringified PDF content here"

# PDF内容をコンテキストに設定する
def set_pdf_context(pdf_content):
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": f"以下の内容を記憶してください。\n\n{pdf_content}"}
        ]
    )
    return response

# 質問に答える
def ask_questions_with_context(questions):
    responses = []
    for question in questions:
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": question}
            ],
            max_tokens=150
        )
        responses.append(response['choices'][0]['message']['content'])
    return responses

# PDFコンテキストを設定
set_pdf_context(pdf_content)

# 質問リスト
questions = ["質問1", "質問2", "質問3", ..., "質問N"]

# 質問に対する回答を取得
responses = ask_questions_with_context(questions)
for i, response in enumerate(responses):
    print(f"質問 {i+1}: {questions[i]}")
    print(f"回答: {response}")
    print()
