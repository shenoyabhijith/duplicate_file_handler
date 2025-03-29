#!/bin/bash

# Set the root directory to scan
ROOT_DIR="/Volumes/Abhi'sHD"
OUTPUT_FILE="duplicate_files_report.txt"

# Function to display help message
display_help() {
    echo "Duplicate File Handler"
    echo "---------------------"
    echo "This script traverses a directory, identifies duplicate files based on their content hash,"
    echo "and provides an option to delete duplicates while preserving one copy."
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Display this help message"
    echo "  -d, --dir DIR  Specify the root directory to scan (default: $ROOT_DIR)"
    echo "  -o, --out FILE Specify the output report file (default: $OUTPUT_FILE)"
    echo ""
}

# Process command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) display_help; exit 0 ;;
        -d|--dir) ROOT_DIR="$2"; shift ;;
        -o|--out) OUTPUT_FILE="$2"; shift ;;
        *) echo "Unknown parameter: $1"; display_help; exit 1 ;;
    esac
    shift
done

# Check if the root directory exists
if [ ! -d "$ROOT_DIR" ]; then
    echo "Error: Directory '$ROOT_DIR' does not exist!"
    exit 1
fi

echo "Starting duplicate file search in: $ROOT_DIR"
echo "This might take a while depending on the number and size of files..."

# Create a temporary directory for storing hash files
TEMP_DIR=$(mktemp -d)
if [ $? -ne 0 ]; then
    echo "Error: Failed to create temporary directory"
    exit 1
fi

# Initialize the output file
echo "Duplicate Files Report" > "$OUTPUT_FILE"
echo "Generated on: $(date)" >> "$OUTPUT_FILE"
echo "Root directory: $ROOT_DIR" >> "$OUTPUT_FILE"
echo "------------------------------------" >> "$OUTPUT_FILE"

# Find all regular files, compute their hash, and store with file path
echo "Generating file hashes..."
find "$ROOT_DIR" -type f -print0 | while IFS= read -r -d $'\0' file; do
    # Skip system files and hidden files
    if [[ "$file" == *"/."* || "$file" == *"/.DS_Store"* ]]; then
        continue
    fi
    
    # Calculate hash and store with path
    hash=$(md5sum "$file" | cut -d' ' -f1)
    echo "$hash $file" >> "$TEMP_DIR/hashes.txt"
    echo -n "." # Show progress
done
echo " Done!"

# Sort the hash file to group duplicates
sort "$TEMP_DIR/hashes.txt" > "$TEMP_DIR/sorted_hashes.txt"

# Find and report duplicates
echo "Analyzing duplicates..."
declare -A duplicates
current_hash=""
duplicate_count=0

while read -r line; do
    hash=$(echo "$line" | cut -d' ' -f1)
    file_path="${line#* }"
    
    if [ "$hash" = "$current_hash" ]; then
        # This is a duplicate
        if [ "${duplicates[$hash]+_}" ]; then
            # Already found this hash before, append to list
            duplicates[$hash]="${duplicates[$hash]}|$file_path"
        else
            # First duplicate of this hash, add to array with previous file
            duplicates[$hash]="$previous_file|$file_path"
            duplicate_count=$((duplicate_count + 1))
        fi
    else
        # New hash
        current_hash="$hash"
        previous_file="$file_path"
    fi
done < "$TEMP_DIR/sorted_hashes.txt"

echo "Found $duplicate_count unique hash values with duplicates"

# Write duplicates to the output file
if [ ${#duplicates[@]} -eq 0 ]; then
    echo "No duplicate files found." >> "$OUTPUT_FILE"
else
    echo "Found duplicate sets: ${#duplicates[@]}" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Create a file to store duplicates for deletion prompt
    echo "" > "$TEMP_DIR/delete_candidates.txt"
    duplicate_index=1
    
    for hash in "${!duplicates[@]}"; do
        IFS='|' read -ra FILES <<< "${duplicates[$hash]}"
        echo "Duplicate Set #$duplicate_index (Hash: $hash)" >> "$OUTPUT_FILE"
        echo "---------------------------------------------" >> "$OUTPUT_FILE"
        
        file_index=1
        for file in "${FILES[@]}"; do
            file_size=$(du -h "$file" | cut -f1)
            echo "[$file_index] $file ($file_size)" >> "$OUTPUT_FILE"
            
            # Store all duplicates except the first one as deletion candidates
            if [ $file_index -gt 1 ]; then
                echo "$duplicate_index,$file_index,$file" >> "$TEMP_DIR/delete_candidates.txt"
            fi
            
            file_index=$((file_index + 1))
        done
        echo "" >> "$OUTPUT_FILE"
        duplicate_index=$((duplicate_index + 1))
    done
fi

echo "Report generated: $OUTPUT_FILE"

# Prompt for duplicate deletion
if [ ${#duplicates[@]} -gt 0 ]; then
    echo ""
    echo "Would you like to delete duplicate files? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "For each duplicate set, the first file will be preserved and you can select which duplicates to delete."
        echo ""
        
        # Read the delete candidates file
        while IFS=, read -r dup_set file_idx file_path; do
            echo "Duplicate Set #$dup_set, File #$file_idx:"
            echo "  $file_path"
            echo "Delete this file? (y/n/q to quit)"
            read -r delete_response
            
            if [[ "$delete_response" =~ ^([qQ][uU][iI][tT]|[qQ])$ ]]; then
                echo "Exiting deletion process."
                break
            elif [[ "$delete_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                echo "Deleting: $file_path"
                rm "$file_path"
                if [ $? -eq 0 ]; then
                    echo "  Deleted successfully."
                else
                    echo "  Error: Failed to delete file."
                fi
            else
                echo "  Skipped deletion."
            fi
            echo ""
        done < "$TEMP_DIR/delete_candidates.txt"
    else
        echo "No files will be deleted."
    fi
fi

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo "Process completed!"
