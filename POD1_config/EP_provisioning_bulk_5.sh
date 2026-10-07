#!/bin/bash

# EP Bulk creation script folder
directory="static_ep"

# Loop through each .py file in the directory
for file in "$directory"/*.py; do
    # Check if there are any .py files in the directory
    if [[ -f "$file" ]]; then
        echo "Executing: python3 $file"
        python3 "$file"
        if [ $? -ne 0 ]; then
            echo "Execution failed for $file"
            exit 1
        fi
    else
        echo "No .py files found in $directory."
        exit 1
    fi
done

echo "Done"