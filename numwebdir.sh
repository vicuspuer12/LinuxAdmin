#!/bin/bash
base_url="<Web URL to scan>"
wordlist="<wordlist directory path>"
output_dir="<output Directory path>"
# Set up file path
mkdir -p dirEnum
# Sanitize and format paths
sanitize_path() {
    echo "$1" | tr -d '[:punct:]' | tr -s ' ' | tr ' ' '_'
}
# Function to perform recursive ffuf scan
scan() {
    local path=$1
    local safe_path=$(sanitize_path "$path")
    echo "Scanning $base_url$path..."
    # Execute ffuf scan and handle output path correctly
    ffuf -c -t 200 -w $wordlist -u "$base_url$path/FUZZ" -fc 403 -o "$output_dir/$safe_path.json" -of json
    # Process results if file exists and is readable
    if [[ -f "$output_dir/$safe_path.json" ]]; then
        jq -r '.results[] | select(.url | endswith("/")) | .url' "$output_dir/$safe_path.json" | while read subdir; do
            # Recursive call to scan subdirectories
            scan "$path$subdir"
        done
    else
        echo "Error: JSON output not found for $path"
    fi
}
# Start scanning
scan "<Web URL directory to scan 1>"
scan "<Web URL directory to scan 2>"
scan "<Web URL directory to scan 3>"
scan "<Web URL directory to scan 4>"
