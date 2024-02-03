#!/bin/bash

# Function to perform addition
add() {
    result=$((num1 + num2))
    echo "Result: $result"
}

# Function to perform subtraction
subtract() {
    result=$((num1 - num2))
    echo "Result: $result"
}

# Function to perform multiplication
multiply() {
    result=$((num1 * num2))
    echo "Result: $result"
}

# Function to perform division
divide() {
    if [ $num2 -eq 0 ]; then
        echo "Error: Division by zero is not allowed."
    else
        result=$(echo "scale=2; $num1 / $num2" | bc)
        echo "Result: $result"
    fi
}

# Main script starts here

# Take user input for two numbers and operation
read -p "Enter first number: " num1
read -p "Enter second number: " num2
read -p "Choose operation (+, -, *, /): " operation

# Perform the selected operation
case $operation in
    "+") add ;;
    "-") subtract ;;
    "*") multiply ;;
    "/") divide ;;
    *) echo "Invalid operation";;
esac

