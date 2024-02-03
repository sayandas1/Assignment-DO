#!/bin/bash

# Get a list of names from the user
read -p "Enter names separated by spaces: " input_names

# Create an associative array to store name occurrences
declare -A name_count

# Iterate through the names and count occurrences
for name in $input_names; do
    ((name_count[$name]++))
done

# Display the name occurrences
echo "Name Occurrences:"
for name in "${!name_count[@]}"; do
    echo "$name: ${name_count[$name]} times"
done

