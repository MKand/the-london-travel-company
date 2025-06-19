import json
import os
from vertexai.preview.vision_models import ImageGenerationModel
import vertexai

vertexai.init(project="o11y-movie-guru", location="us-central1")

generation_model = ImageGenerationModel.from_pretrained("imagen-4.0-generate-preview-05-20")

def load_data(filename):
    """Loads a JSON file from the current directory."""
    if not os.path.exists(filename):
        print(f"Error: {filename} not found in the current directory.")
        return None
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def create_image_prompts():
    """
    Loads adventure and location data, then generates and prints
    a detailed image prompt for each adventure.
    """
    adventures = load_data('./lovecraftian_adventures.json')
    locations = load_data('./lovecraftian_locations.json')

    if not adventures or not locations:
        print("Could not load data. Exiting.")
        return

    # Create a quick lookup dictionary for locations
    locations_map = {loc['location_id']: loc for loc in locations}

    print("--- Generated Image Prompts ---\n")

    for adventure in adventures:
        location_id = adventure.get('location_id')
        location = locations_map.get(location_id)
        adventure_id = adventure.get('adventure_id')


        if not location:
            print(f"Warning: Location not found for adventure ID {adventure['adventure_id']}")
            continue

        # --- Prompt Engineering Logic ---
        style = adventure.get('style', 'Investigative').lower()
        title = adventure.get('title', 'An unknown adventure')
        loc_name = location.get('name', 'an unknown location')
        
        # Define artistic styles based on the adventure's 'style'
        art_style_map = {
            'scholarly': 'cinematic, dark academia, atmospheric, suspenseful, shadows and dust motes',
            'investigative': 'photorealistic, neo-noir, cinematic lighting, mysterious, unsettling',
            'high-risk': 'gritty photorealism, found footage style, sense of dread, claustrophobic',
            'extreme': 'surreal horror, non-euclidean angles, dark fantasy art, epic scope',
            'relaxing': 'impressionistic oil painting, slightly eerie but calm, New England gothic'
        }
        
        art_style = art_style_map.get(style, 'cinematic horror')

        # Construct the detailed prompt
        prompt = (
            f"Masterpiece in the style of {art_style}, cosmic horror. "
            f"The scene depicts '{title}' in the town of {loc_name}. "
            f"({adventure['description']})."
            f"The overall mood is {style}, with a deep sense of underlying dread."
        )

        print(f"Adventure ID: {adventure_id}")
        generate_image(prompt, adventure_id)



def generate_image(prompt, adventure_id):
    images = generation_model.generate_images(
        prompt=prompt,
        number_of_images=4,
        aspect_ratio="1:1",
        negative_prompt="Do not add the description text to the image",
        person_generation="allow_adult",
        safety_filter_level="block_few",
        add_watermark=True,
    )
    for i, image in enumerate(images):
        # Define a unique filename for each image
        filename = os.path.join("images", f"{adventure_id}_{i}.png")
        
        # Save the raw image bytes to the specified file
        # The 'wb' mode is crucial for writing binary data
        with open(filename, "wb") as f:
            f.write(image._image_bytes)
        
        print(f"Saved image to {filename}")


if __name__ == '__main__':
    create_image_prompts()