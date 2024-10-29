import os
import numpy as np
from collections import Counter
import webcolors
from PIL import Image

def get_dominant_color(segmented_image):
    pixels = segmented_image.reshape(-1, 3)
    pixels = pixels[~np.all(pixels == 0, axis=1)]  # Remove black pixels (background)

    if len(pixels) == 0:
        return (0, 0, 0)  # Return black if no pixels are left

    color_counts = Counter(map(tuple, pixels))
    dominant_color = color_counts.most_common(1)[0][0]
    return dominant_color

def rgb_to_color_name(rgb):
    try:
        color_name = webcolors.rgb_to_name(rgb)
    except ValueError:
        closest_name = min(webcolors.CSS3_HEX_TO_NAMES.keys(),key=lambda name: np.linalg.norm(np.array(webcolors.hex_to_rgb(name)) - np.array(rgb)))
        color_name = webcolors.CSS3_HEX_TO_NAMES[closest_name]
    return color_name

def save_segmented_class(class_idx, class_name, pred_seg, image_np, folder):
    mask = (pred_seg == class_idx).numpy()
    segmented_image = np.zeros_like(image_np)

    # Apply mask
    segmented_image[mask] = image_np[mask]

    # Save segmented image
    segmented_image_pil = Image.fromarray(segmented_image)
    output_path = os.path.join(folder, f"{class_name}.png")
    segmented_image_pil.save(output_path)

    # Get dominant color
    dominant_color = get_dominant_color(segmented_image)
    color_name = rgb_to_color_name(dominant_color)

    return color_name
