#!/bin/bash

# Function to check eligibility
check_eligibility() {
    if [ $age -ge 18 ]; then
        echo "You are eligible to vote."
    else
        echo "Sorry, you are not eligible to vote yet."
    fi
}

# Main script starts here

# Take user input for age
read -p "Enter your age: " age

# Check eligibility
check_eligibility

