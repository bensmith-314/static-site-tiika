import json

# Load original JSON
with open("/Users/bensmith/Desktop/static-site-tiika/json/original_art_pieces.json", "r") as f:
    original_data = json.load(f)

# Convert list to dictionary keyed by 'prefix'
converted_data = {"art_pieces": {}}
for item in original_data["art_pieces"]:
    prefix = str(item.pop("prefix"))
    converted_data["art_pieces"][prefix] = item

# Save the new JSON
with open("converted_art_pieces.json", "w") as f:
    json.dump(converted_data, f, indent=2)