#!/bin/bash

# Directory containing the .pdb files

# Find all .pdb files and process them
fd ${1:-.} "./1_min/" -a -t f -e "pdb" | while read -r file; do
    # Extract the filename from the full path
    filename=$(basename "$file" .pdb)
    dirname=$(dirname "$file")
    pdb=${filename:0:4}

    # Extract chain information
    chains=$(echo "$file" | perl -ne 'if (/_([A,B]+)_([B,C,D,E]+)\..+/) { print "$1 $2\n"; }')
    first=$(echo "$chains" | awk '{print $1}')
    second=$(echo "$chains" | awk '{print $2}')

    echo "$first and $second for $filename"
    # Format chain names if necessary
    if [ ${#first} -eq 2 ]; then
        first="${first:0:1},${first:1:1}"
    fi
    if [ ${#second} -eq 2 ]; then
        second="${second:0:1},${second:1:1}"
    fi
    echo "$first and $second for $filename"

    # Process the file if it contains "wt" (wild type)
    if [[ ${filename} == *"wt"* ]]; then
        # Wild-type file, extracting both chains
        echo "Processing wild type file: $file"
        echo "pdb_selchain -${first} "$file" | perl -00 -pe 's/TER\nTER\n//' > "${dirname}/${pdb}_${first//,/}.pdb""
        pdb_selchain -${first} "$file" | perl -00 -pe 's/TER\nTER\n//' > "${dirname}/${pdb}_${first//,/}.pdb"
        pdb_selchain -${second} "$file" | perl -00 -pe 's/TER\nTER\n//' > "${dirname}/${pdb}_${second//,/}.pdb"
        
    else
        # Extract mutation information
        mutation=$(echo "$filename" | cut -c 6)
        mut_pdb=$(echo "$filename" | sed -E 's/^(([^_]*_){2}[^_]*).*/\1/')

        # Select the appropriate chain based on mutation
        if [[ "${first}" == *"${mutation}"* ]]; then
            echo "Processing file: $file (chain $first)"
            pdb_selchain -${first} "$file" > "${dirname}/${mut_pdb}.pdb"
        else
            echo "Processing file: $file (chain $second)"
            pdb_selchain -${second} "$file" > "${dirname}/${mut_pdb}.pdb"
        fi

        # Clean up the PDB file by removing "TER" lines
        grep -v "TER" "${dirname}/${mut_pdb}.pdb" > "${dirname}/${mut_pdb}.pdb.tmp" && mv "${dirname}/${mut_pdb}.pdb.tmp" "${dirname}/${mut_pdb}.pdb"
    fi
done
