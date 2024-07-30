import fitz  # PyMuPDF
from PIL import Image
import pytesseract
import io

def extract_images_from_pdf(pdf_path):
    # PDFファイルを開く
    pdf_document = fitz.open(pdf_path)
    images = []
    
    # 各ページを走査
    for page_num in range(len(pdf_document)):
        page = pdf_document[page_num]
        image_list = page.get_images(full=True)
        
        for img_index, img in enumerate(image_list):
            xref = img[0]
            base_image = pdf_document.extract_image(xref)
            image_bytes = base_image["image"]
            image_ext = base_image["ext"]
            image = Image.open(io.BytesIO(image_bytes))
            images.append(image)
    
    return images

def ocr_images(images):
    text_list = []
    for image in images:
        text = pytesseract.image_to_string(image, lang='eng')  # 'eng'の部分を適切な言語コードに変更
        text_list.append(text)
    
    return text_list

pdf_path = 'path_to_your_pdf.pdf'
images = extract_images_from_pdf(pdf_path)
texts = ocr_images(images)

for i, text in enumerate(texts):
    print(f"Text from image {i+1}:")
    print(text)
    print("-" * 50)
