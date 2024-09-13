import base64
import json
import os

directory = './'

image_extensions = ["jpg", "jpeg", "png", "gif", "bmp"]

data = {}

for filename in os.listdir(directory):
    if filename.split(".")[-1].lower() in image_extensions:
        print(f"Processing {filename}")
        with open(f'{directory}/{filename}', 'rb') as image_file:
            encoded_string = base64.b64encode(
                image_file.read()).decode('utf-8')
        data[filename.split(".")
             [0]] = f"data:image/jpeg;base64,{encoded_string}"
    else:
        print(f"Ignoring {filename}")

with open('output.json', 'w') as outfile:
    json.dump(data, outfile, indent=2)
