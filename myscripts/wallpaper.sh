#!/bin/bash

# Prompt the user for the image path
read -p "Enter the path to the image: " image_path

# Check if the provided path is valid and if the file exists
if [ -f "$image_path" ]; then
    # Run wal with the provided image path
    wal -i "$image_path"
    betterlockscreen -u "$image_path" --fx blur
    xdotool key super+F5
    echo "Wallpaper set successfully!"

else
    echo "Error: The file at '$image_path' does not exist. Please provide a valid image path."
fi
