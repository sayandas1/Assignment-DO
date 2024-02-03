#!/bin/bash

# Get input numbers from the user
read -p "Enter numbers separated by spaces: " input_numbers

# Use the 'sort' command to sort the numbers
sorted_numbers=$(echo $input_numbers | tr ' ' '\n' | sort -n)

# Display the sorted numbers
echo "Sorted Numbers: $sorted_numbers"

