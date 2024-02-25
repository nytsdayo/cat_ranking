import json
import urllib.parse

# Load the JSON data
with open('cat_breeds_data_translated.json', 'r', encoding='utf-8') as file:
    cat_breeds_data = json.load(file)

# Decode each name entry in the JSON data
for breed in cat_breeds_data:
    breed['name'] = urllib.parse.unquote(breed['name'])

# Save the corrected data to a new file
with open('cat_breeds_data_corrected.json', 'w', encoding='utf-8') as file:
    json.dump(cat_breeds_data, file, ensure_ascii=False, indent=2)
