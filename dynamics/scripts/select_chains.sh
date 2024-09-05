#!/bin/bash

# Directory containing the .pdb files

# Find all .pdb files and process them
fd ${1:-.} "./1_min/" -a -t f -e "pdb" | while read -r file; do
    # Extract the filename from the full path
    filename=$(basename "$file" .pdb)
    dirname=$(dirname "$file")
    pdb=${filename:0:4}

    chains=$(echo "$file" | perl -ne 'if (/_(\w{1,2})_(\w{1,2})\..+/) { print "$1 $2\n"; }')
    first=$(echo "$chains" | awk '{print $1}')
    second=$(echo "$chains" | awk '{print $2}')

    if [ ${#first} -eq 2 ]; then
        first="${first:0:1},${first:1:1}"
    fi
    if [ ${#second} -eq 2 ]; then
        second="${second:0:1},${second:1:1}"
    fi
    cd $dirname

    if [[ ${filename} == *"wt"* ]]; then
        # echo "wild type file, Extracting both chains"
        echo $file
        pdb_selchain -${first} ${file} | perl -00 -pe 's/TER\nTER\n//' > "${dirname}/${pdb}_${first//,/}.pdb"
        pdb_selchain -${second} ${file} | perl -00 -pe 's/TER\nTER\n//' > "${dirname}/${pdb}_${second//,/}.pdb"
        
    else
        # Extract the 6th character from the filename
        mutation=$(echo "$filename" | cut -c 6)
        mut_pdb=$(echo "$filename" | sed -E 's/^(([^_]*_){2}[^_]*).*/\1/')

        if [[ "${first}" == *"${mutation}"* ]]; then
        echo $file
            pdb_selchain -${first} ${file} > "${dirname}/${mut_pdb}.pdb"
            grep -v "TER" "${dirname}/${mut_pdb}.pdb" > "temp_file" && mv "temp_file" "${dirname}/${mut_pdb}.pdb"
        else
        echo $file
            pdb_selchain -${second} ${file} > "${dirname}/${mut_pdb}.pdb"
            grep -v "TER" "${dirname}/${mut_pdb}.pdb" > "temp_file" && mv "temp_file" "${dirname}/${mut_pdb}.pdb"
        fi
    fi
done
