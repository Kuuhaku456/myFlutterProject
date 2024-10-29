import os
import re
from flask import Flask, request, jsonify
from segmen import segment_image, save_segmented_images  # Function for image segmentation
from color_predict_model import save_segmented_class   # Import untuk prediksi warna shirt dan pants
import google.generativeai as genai
import json
from flask_cors import CORS
# API key Google
GOOGLE_API_KEY = "AIzaSyAakCO0wQdenLCBv7lZphEWoAjounEnFGw"
genai.configure(api_key=GOOGLE_API_KEY)
formatted_data = []    
json_string = """
{
  "nuansa": "cerah",
  "baju": "putih",
  "celana": "hitam",
  "hexabaju": 0xFFFFFF,
  "hexacelana": 0xFF00000,
}
"""

json_cocok = """
{
  "persen": "0%",
  "status": "cocok",  
}
"""
app = Flask(__name__)
CORS(app)

upload_folder = './uploaded_images'
if not os.path.exists(upload_folder):
    os.makedirs(upload_folder)

output_folder = './output_images/segmented_images'
if not os.path.exists(output_folder):
    os.makedirs(output_folder)
    
@app.route('/', methods=['GET'])
def home():
    return jsonify(message="Welcome to the Flask app!"), 200

@app.route('/test-post', methods=['POST'])
def test_post():
    data = request.get_json()
    if data:
        return jsonify(message="Data received", data=data), 200
    else:
        return jsonify(message="No data received"), 400
    

@app.route('/upload-image', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({"error": "No image file provided."}), 400
    image_file = request.files['image']
    image_filename = image_file.filename
    image_path = os.path.join(upload_folder, image_filename)
    image_file.save(image_path)  
    pred_seg, image_np = segment_image(image_path)
    save_segmented_images(pred_seg, image_np, output_folder)
    return jsonify({"message": "Image uploaded and segmented successfully!"}), 200


@app.route('/process-image', methods=['POST'])
def process_image():
    if 'image' not in request.files:
        return jsonify({"error": "No image file provided."}), 400
    image_file = request.files['image']
    image_filename = image_file.filename
    image_path = os.path.join(upload_folder, image_filename)
    image_file.save(image_path)  
    pred_seg, image_np = segment_image(image_path)
    save_segmented_images(pred_seg, image_np, output_folder)
    face_skin_tone = save_segmented_class(11, "face", pred_seg, image_np, os.path.join(output_folder, 'face'))  # Class index for face
    shirt_color = save_segmented_class(4, "shirt", pred_seg, image_np, os.path.join(output_folder, 'shirt'))  # Class index for shirt
    pants_color = save_segmented_class(6, "pants", pred_seg, image_np, os.path.join(output_folder, 'pants'))  # Class index for pants
    prompt = f"aku punya warna kulit {face_skin_tone}, warna baju {shirt_color}, dan warna celana {pants_color}, jawab apakah cocok atau tidak dan berikan berapa persen kecocokannya jadi jawabannya dalam bentuk json seperti ini : {json_cocok}"
    model_ai = genai.GenerativeModel('gemini-1.5-flash')
    response = model_ai.generate_content([prompt])
    match_result = response.text
    match1 = re.search(r'"persen":\s*"([^"]+)"\s*,\s*"status":\s*"([^"]+)"', match_result)
    if match1:
        persen = match1.group(1)
        status = match1.group(2)
        final_match_result = {
            "persen": persen,
            "status": status
    }
    prompt_recommend = f"Generate JSON data for clothing color recommendations based on a {face_skin_tone} skin tone. Each JSON object should contain the following keys: nuansa (shade), baju (shirt), celana (pants), hexabaju (hex code for shirt color), and hexacelana (hex code for pants color). Provide a variety of color combinations, including both warm and cool tones. Example JSON format seperti contoh ini : {json_string}, without any descriptiona and explanaton at all, so just the JSON, min 10"
    response_recommend = model_ai.generate_content([prompt_recommend])
    recommendation_result = response_recommend.text
    recommendation_result_final = recommendation_result.replace('```json', '').replace('```', '').strip()
    recommendation_result_json = json.loads(recommendation_result_final)
    print(f"Sebelum di format HEXA : \n {recommendation_result_json} \n")
    for item in recommendation_result_json:
        item['hexabaju'] = format_hex_color(item['hexabaju'])
        item['hexacelana'] = format_hex_color(item['hexacelana'])
    print(f"Setelah di format HEXA : \n {recommendation_result_json} \n")
    print(face_skin_tone)
    print(shirt_color)
    print(pants_color)
    print(final_match_result)
    return jsonify({
        "face_skin_tone": face_skin_tone,  
        "shirt_color": shirt_color,  
        "pants_color": pants_color,  
        "outfit_match": final_match_result,  
        "recommend_color": recommendation_result_json,  
    }), 200
 
def format_hex_color(hex_code):
    hex_code = hex_code.lstrip('#').lstrip('0x').upper()
    if len(hex_code) == 6:
        return f"0xFF{hex_code}"
    elif len(hex_code) == 3:
        return f"0xFF{''.join([c*2 for c in hex_code])}"
    elif len(hex_code) < 6:
        hex_code = hex_code.zfill(6)
        return f"0xFF{hex_code}"
    else:
        raise ValueError(f"Invalid hex code format: {hex_code}")

if __name__ == '__main__':
    app.run(port=2050, threaded=True)
