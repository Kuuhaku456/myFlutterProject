import os
from transformers import SegformerImageProcessor, AutoModelForSemanticSegmentation
from PIL import Image
import torch.nn as nn
import numpy as np

# Load model and processor
processor = SegformerImageProcessor.from_pretrained("mattmdjaga/segformer_b2_clothes")
model = AutoModelForSemanticSegmentation.from_pretrained("mattmdjaga/segformer_b2_clothes")

def segment_image(image_path):
    # Load the image
    image = Image.open(image_path)

    # Preprocess image
    inputs = processor(images=image, return_tensors="pt")

    # Model inference
    outputs = model(**inputs)
    logits = outputs.logits.cpu()

    # Upsample logits to the image size
    upsampled_logits = nn.functional.interpolate(
        logits,
        size=image.size[::-1],
        mode="bilinear",
        align_corners=False,
    )

    # Get segmentation map
    pred_seg = upsampled_logits.argmax(dim=1)[0]

    # Convert PIL image to NumPy array
    image_np = np.array(image)

    return pred_seg, image_np

def save_segmented_images(pred_seg, image_np, output_folder):
    # Class indices (adjust as per your model's classes)
    face_class_idx = 11  # Replace with actual class index for face
    shirt_class_idx = 4   # Replace with actual class index for shirt
    pants_class_idx = 6   # Replace with actual class index for pants

    # Save segmented images with unique filenames
    for class_idx, class_name in zip(
        [face_class_idx, shirt_class_idx, pants_class_idx],
        ['face', 'shirt', 'pants']
    ):
        mask = (pred_seg == class_idx).numpy()  # Create mask for the class
        segmented_image = np.zeros_like(image_np)  # Create empty array for segmented image

        # Apply mask to the image
        segmented_image[mask] = image_np[mask]

        # Save the segmented image
        save_segment_with_unique_name(segmented_image, class_name, output_folder)

def save_segment_with_unique_name(segmented_image, class_name, output_folder):
    class_folder = os.path.join(output_folder, class_name)
    
    if not os.path.exists(class_folder):
        os.makedirs(class_folder)

    count = 1
    while True:
        filename = f"{class_name}{count}.png"
        file_path = os.path.join(class_folder, filename)
        if not os.path.exists(file_path):
            break
        count += 1

    # Convert the segmented image back to a PIL Image and save it
    segmented_image_pil = Image.fromarray(segmented_image)
    segmented_image_pil.save(file_path)
    print(f"Saved {class_name} segment to {file_path}")
