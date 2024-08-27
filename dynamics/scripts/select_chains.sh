#!/bin/bash

# Directory containing the .pdb files

# Find all .pdb files and process them
fd . "./1_min/" -a -t f -e "pdb" | while read -r file; do
    # Extract the filename from the full path
    filename=$(basename "$file" .pdb)
    dirname=$(dirname "$file")

    cd $dirname
    if [[ ${filename} == *"wt"* ]]; then
        # echo "wild type file, Extracting both chains"
        wt_pdb=${filename:0:4}
        chains=$(echo "$filename" | sed -E 's/^.*_wt_//')
        first=$(echo "$chains" | awk -F'_' '{print $1}')
        second=$(echo "$chains" | awk -F'_' '{print $2}')

        
        if [ ${#first} -eq 2 ]; then
            first="${first:0:1},${first:1:1}"
        fi
        if [ ${#second} -eq 2 ]; then
            second="${second:0:1},${second:1:1}"
        fi

        pdb_selchain -${first} ${file} | perl -00 -pe 's/TER\nTER\n//' > "${dirname}/${wt_pdb}_${first//,/}.pdb"
        pdb_selchain -${second} ${file} | perl -00 -pe 's/TER\nTER\n//' > "${dirname}/${wt_pdb}_${second//,/}.pdb"
        
    else
        # Extract the 6th character from the filename
        char=$(echo "$filename" | cut -c 6)
        mut_pdb=$(echo "$filename" | sed -E 's/^(([^_]*_){2}[^_]*).*/\1/')

        # Check if the 6th character is A, B, or C
        if [[ "$char" == "A" || "$char" == "B" || "$char" == "C" ]]; then
            # Print the filename and character for debugging
            # echo "Processing file: $filename with character: $char"
            pdb_selchain -${char} ${file} > "${dirname}/${mut_pdb}.pdb"
            grep -v "TER" "${dirname}/${mut_pdb}.pdb" > "temp_file" && mv "temp_file" "${dirname}/${mut_pdb}.pdb"

        fi
    fi


done

