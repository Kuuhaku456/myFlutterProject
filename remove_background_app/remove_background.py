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
    image = Image.open(image_path).convert("RGB")  # Ensure the image is in RGB format

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
    background_class_idx = 0  # Class index for background

    # Create masks
    background_mask = (pred_seg == background_class_idx).numpy()
    person_mask = np.logical_not(background_mask)  # Everything that is not background

    # Save segmented images
    segmented_background = np.zeros_like(image_np)  # Background image
    segmented_background[background_mask] = image_np[background_mask]

    segmented_person = np.zeros_like(image_np)  # Person image (everything else)
    segmented_person[person_mask] = image_np[person_mask]

    # Save both images
    save_segment_with_unique_name(segmented_background, 'background', output_folder)
    # Save person image specifically as '1.png'
    save_segment_as_specific_name(segmented_person, 'person', output_folder, '1.png')

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

def save_segment_as_specific_name(segmented_image, class_name, output_folder, specific_name):
    class_folder = os.path.join(output_folder, class_name)
    
    if not os.path.exists(class_folder):
        os.makedirs(class_folder)

    file_path = os.path.join(class_folder, specific_name)

    # Convert the segmented image back to a PIL Image and save it
    segmented_image_pil = Image.fromarray(segmented_image)
    segmented_image_pil.save(file_path)
    print(f"Saved {class_name} segment to {file_path}")

def remove_background(image_path, output_folder):
    pred_seg, image_np = segment_image(image_path)
    save_segmented_images(pred_seg, image_np, output_folder)
    return os.path.join(output_folder, 'person')
