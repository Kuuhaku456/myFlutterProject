from flask import Flask, request, jsonify, send_file
import os
from rembg import remove
from PIL import Image
import numpy as np
import cv2
from io import BytesIO

app = Flask(__name__)
output_folder = "output_images"

# Create output folder if it doesn't exist
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

def refine_edges(image):
    # Convert PIL Image to NumPy array
    img_np = np.array(image)

    # Convert to grayscale
    gray = cv2.cvtColor(img_np, cv2.COLOR_RGBA2GRAY)

    # Apply a binary threshold to get a binary image
    _, binary = cv2.threshold(gray, 1, 255, cv2.THRESH_BINARY)

    # Perform morphological operations to clean edges
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
    cleaned_binary = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)

    # Create a mask from the cleaned binary image
    mask = cv2.cvtColor(cleaned_binary, cv2.COLOR_GRAY2RGBA)

    # Use the mask to keep only the non-background areas from the original image
    refined_image = cv2.bitwise_and(img_np, mask)

    return Image.fromarray(refined_image)

@app.route('/upload', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400

    image_file = request.files['image']
    
    # Save the uploaded image
    image_path = os.path.join(output_folder, image_file.filename)
    image_file.save(image_path)

    # Open the image using Pillow
    input_image = Image.open(image_path)

    # Remove the background using rembg
    output_image = remove(input_image)

    # Refine edges
    refined_image = refine_edges(output_image)

    # Prepare folders for saving the images
    background_folder = os.path.join(output_folder, 'background')
    person_folder = os.path.join(output_folder, 'person')

    # Create folders if they do not exist
    os.makedirs(background_folder, exist_ok=True)
    os.makedirs(person_folder, exist_ok=True)

    # Save the original image as background (just for this example)
    input_image.save(os.path.join(background_folder, image_file.filename))

    # Save the output image with refined edges
    output_image_path = os.path.join(person_folder, image_file.filename)
    refined_image.save(output_image_path)

    # Return the person image
    with open(output_image_path, 'rb') as f:
        img_data = BytesIO(f.read())
        img_data.seek(0)  # Move to the start of the BytesIO buffer

    return send_file(img_data, mimetype='image/png', as_attachment=True, download_name='person_image.png')

if __name__ == '__main__':
    app.run(port=5000)
