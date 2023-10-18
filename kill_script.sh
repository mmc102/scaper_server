#!/bin/bash

# Define the path to the file
file="kill.txt"

# Check if the file exists
if [ ! -f "$file" ]; then
    echo "File $file not found."
    exit 1
fi

# Read each line in the file
while IFS= read -r container_id
do
    # Check if the container ID is not empty
    if [ -n "$container_id" ]; then
        # Stop the container using 'docker kill'
        docker kill "$container_id"
        
        # Check the exit status of 'docker kill'
        if [ $? -eq 0 ]; then
            echo "Container $container_id stopped successfully."
            
            # Remove the line from the file
            sed -i "/$container_id/d" "$file"
            
            echo "Line removed from $file."
        else
            echo "Failed to stop container $container_id."
        fi
    fi
done < "$file"
