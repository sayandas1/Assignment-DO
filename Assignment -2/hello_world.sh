#!/bin/bash

# Check if the user provided a count as a command line argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <count>"
    exit 1
fi

# Extract the count from the command line argument
count=$1

# Loop to print "Hello, World!" as per the count
for ((i=1; i<=count; i++)); do
    echo "Hello, World!"
done

