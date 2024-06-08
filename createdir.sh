#!/bin/bash

# Base directory containing the files

# Find all .pdb files
fd -a -e "pdb" . "00_dataset" | while read -r file; do
    # Extract the file name
    file_name=$(basename "$file")
    
    pdb="${file_name:0:4}"
    # Extract the desired directory structure from the file name
    dir_name=$(echo "$file_name" | sed -E 's/^(.{4}_[^_]*_[^_]*)_.*/\1/')
    # Create the new directory structure
    new_dir="$base_dir/$pdb/$dir_name"
    mkdir -p "$new_dir"
    
    # Move the file to the new directory
    mv "$file" "$new_dir"
    cp "./automatize.tcl" "${new_dir}/${dir_name}_auto.tcl"
    sd "INPUT" ${file} "${new_dir}/${dir_name}_auto.tcl" 
done

