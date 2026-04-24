#!/usr/bin/env python3
"""
Generate square collages for milestone art days (1, 4, 9, 16, 25, 36, 49, 64, etc.)
Usage: python create-art-square.py <day_number> <input_folder> <output_file>
Example: python create-art-square.py 1764 /path/to/everydays /path/to/output/day-1764-collage.jpg
"""

import sys
import os
import math
from PIL import Image

def create_square_collage(day_number, input_folder, output_path):
    # Check if day is a perfect square
    sqrt = int(math.sqrt(day_number))
    if sqrt * sqrt != day_number:
        print(f"Error: {day_number} is not a perfect square!")
        return False
    
    print(f"Creating {sqrt}x{sqrt} collage for day {day_number}...")
    
    # Collect image paths (assumes 0001.jpg, 0002.jpg, etc.)
    image_paths = []
    for i in range(1, day_number + 1):
        # Try different extensions
        for ext in ['.jpg', '.JPG', '.jpeg', '.png']:
            filename = f"{i:04d}{ext}"  # Format as 0001, 0002, etc.
            filepath = os.path.join(input_folder, filename)
            if os.path.exists(filepath):
                image_paths.append(filepath)
                break
        else:
            # Also try with full filename from everydays (0001-Title.jpg)
            for file in os.listdir(input_folder):
                if file.startswith(f"{i:04d}-") and file.endswith(('.jpg', '.jpeg', '.png')):
                    image_paths.append(os.path.join(input_folder, file))
                    break
    
    if len(image_paths) != day_number:
        print(f"Error: Found {len(image_paths)} images, expected {day_number}")
        return False
    
    # Get dimensions from first image
    with Image.open(image_paths[0]) as first_img:
        tile_width, tile_height = first_img.size
    
    print(f"Each tile: {tile_width}x{tile_height}")
    
    # Create blank canvas
    canvas_width = tile_width * sqrt
    canvas_height = tile_height * sqrt
    collage = Image.new('RGB', (canvas_width, canvas_height))
    
    print(f"Canvas size: {canvas_width}x{canvas_height}")
    print("Compositing images...")
    
    # Paste images
    for idx, img_path in enumerate(image_paths):
        if idx % 100 == 0:
            print(f"  Processing image {idx}/{day_number}...")
        
        row = idx // sqrt
        col = idx % sqrt
        
        with Image.open(img_path) as img:
            # Resize if needed (in case not all same size)
            if img.size != (tile_width, tile_height):
                img = img.resize((tile_width, tile_height), Image.Resampling.LANCZOS)
            
            x = col * tile_width
            y = row * tile_height
            collage.paste(img, (x, y))
    
    # Save
    print(f"Saving to {output_path}...")
    collage.save(output_path, quality=95, optimize=True)
    print(f"✓ Done! Collage saved to {output_path}")
    print(f"  Final size: {canvas_width}x{canvas_height}")
    
    return True

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python create-art-square.py <day_number> <input_folder> <output_file>")
        print("Example: python create-art-square.py 1764 ~/everydays ~/output/day-1764.jpg")
        sys.exit(1)
    
    day = int(sys.argv[1])
    input_dir = sys.argv[2]
    output_file = sys.argv[3]
    
    if not os.path.isdir(input_dir):
        print(f"Error: Input folder '{input_dir}' does not exist")
        sys.exit(1)
    
    # Install Pillow if needed
    try:
        from PIL import Image
    except ImportError:
        print("Pillow not installed. Install with: pip3 install Pillow")
        sys.exit(1)
    
    success = create_square_collage(day, input_dir, output_file)
    sys.exit(0 if success else 1)