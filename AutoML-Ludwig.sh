#!/bin/bash

# Step 1: Check if Ludwig is installed
if ! command -v ludwig &> /dev/null
then
    echo "Ludwig could not be found. Attempting to install..."
    pip install ludwig || { echo "Failed to install Ludwig. Please install Python and pip, then try again."; exit 1; }
fi

# Step 2: Prompt the user for the dataset file name
echo "Please enter the name of your dataset file (e.g., dataset.csv):"
read DATASET_FILE
if [ ! -f "$DATASET_FILE" ]; then
    echo "Dataset file not found!"
    exit 1
fi

# Step 3: Display configuration options from the CSV file
echo "Available model configurations:"
IFS=$'\n' read -d '' -r -a lines < configurations.csv

for i in "${!lines[@]}"; do
  if [ $i -eq 0 ]; then continue; fi # Skip header
  IFS=',' read -r -a line <<< "${lines[$i]}"
  echo "$i. ${line[0]}"
done

echo "Please select a model configuration (enter the number):"
read selection

# Validate selection
if [ "$selection" -lt 1 ] || [ "$selection" -gt ${#lines[@]} ]; then
    echo "Invalid selection!"
    exit 1
fi

# Step 4: Extract the selected configuration and save it to a YAML file
IFS=',' read -r -a selected_line <<< "${lines[$selection]}"
CONFIG="${selected_line[1]}"
CONFIG_FILE="model_config.yaml"
echo -e $CONFIG > $CONFIG_FILE

# Step 5: Run Ludwig with the selected configuration
echo "Training model using the selected configuration..."
ludwig train \
  --dataset $DATASET_FILE \
  --config_file $CONFIG_FILE \
  --output_directory results

echo "Training complete. Results are saved in the 'results' directory."
