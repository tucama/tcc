#!/bin/bash

# Directory containing the .pdb files

# Find all .pdb files and process them


fd "${1:-.}" "${2:-"./1_min/"}" -a -t f -e "pdb" | while read -r file; do
    # Extract the filename from the full path
    filename=$(basename "$file" .pdb)
    dirname=$(dirname "$file")

    # Process the file if it contains "wt" (wild type)
    if [[ ${filename} == *"wt"* ]]; then

        pdb=$(echo "$filename"|  perl -ne 'print "$1\n" if /([0-9a-z]{4})_wt_([A-Z]{1,})_([A-Z]{1,})$/' )
        first_chain=$(echo "$filename"|  perl -ne 'print "$2\n" if /([0-9a-z]{4})_wt_([A-Z]{1,})_([A-Z]{1,})$/' )
        second_chain=$(echo "$filename"|  perl -ne 'print "$3\n" if /([0-9a-z]{4})_wt_([A-Z]{1,})_([A-Z]{1,})$/' )

        
        if [ ${#first_chain} -gt 1 ]; then
            first_chain_pdb_tool=$(echo $first_chain | sed 's/./&,/g' | sed 's/,$//')
        else
            first_chain_pdb_tool=$first_chain
        fi

        if [ ${#second_chain} -gt 1 ]; then
            second_chain_pdb_tool=$(echo $second_chain | sed 's/./&,/g' | sed 's/,$//')
        else
            second_chain_pdb_tool=$second_chain
        fi

        # # debug
        # echo -e "file:${file}\nfilename:${filename}\npdb:${pdb}\nfirst_chain:${first_chain}\nsecond_chain:${second_chain}"
        # echo "pdb_selchain -${first_chain_pdb_tool} "$file" | perl -00 -pe 's/TER\nTER\n//' > "${dirname}/${pdb}_wt_${first_chain}.pdb""
        # echo "pdb_selchain -${second_chain_pdb_tool} "$file" | perl -00 -pe 's/TER\nTER\n//' > "${dirname}/${pdb}_wt_${second_chain}.pdb""

        # # Wild-type file, extracting both chains
        # echo "Processing wild type file: $file"

        wt_first_chain_pdb="${dirname}/${pdb}_wt_${first_chain}.pdb"
        wt_second_chain_pdb="${dirname}/${pdb}_wt_${second_chain}.pdb"

        pdb_selchain -${first_chain_pdb_tool} "$file" | perl -00 -pe 's/TER\nTER\n//' > "${wt_first_chain_pdb}"
        pdb_selchain -${second_chain_pdb_tool} "$file" | perl -00 -pe 's/TER\nTER\n//' > "${wt_second_chain_pdb}"
        
    else
        pdb=$(echo "$filename"|  perl -ne 'print "$1\n" if /([0-9a-z]{4})_([A-Z])_([A-Z0-9]{2,})_([A-Z]{1,})_([A-Z]{1,})$/' )
        mutated_chain=$(echo "$filename"|  perl -ne 'print "$2\n" if /([0-9a-z]{4})_([A-Z])_([A-Z0-9]{2,})_([A-Z]{1,})_([A-Z]{1,})$/' )
        mutation=$(echo "$filename"|  perl -ne 'print "$3\n" if /([0-9a-z]{4})_([A-Z])_([A-Z0-9]{2,})_([A-Z]{1,})_([A-Z]{1,})$/' )
        first_chain=$(echo "$filename"|  perl -ne 'print "$4\n" if /([0-9a-z]{4})_([A-Z])_([A-Z0-9]{2,})_([A-Z]{1,})_([A-Z]{1,})$/' )
        second_chain=$(echo "$filename"|  perl -ne 'print "$5\n" if /([0-9a-z]{4})_([A-Z])_([A-Z0-9]{2,})_([A-Z]{1,})_([A-Z]{1,})$/' )

        if [ ${#first_chain} -gt 1 ]; then
            first_chain_pdb_tool=$(echo $first_chain | sed 's/./&,/g' | sed 's/,$//')
        else
            first_chain_pdb_tool=$first_chain
        fi

        if [ ${#second_chain} -gt 1 ]; then
            second_chain_pdb_tool=$(echo $second_chain | sed 's/./&,/g' | sed 's/,$//')
        else
            second_chain_pdb_tool=$second_chain
        fi

        # # debug
        # echo -e "file:${file}\nfilename:${filename}\npdb:${pdb}\nfirst_chain:${first_chain}\nsecond_chain:${second_chain}\nmutation:${mutation}\nmut_chain:${mutated_chain}"
        # echo "pdb_selchain -${first_chain_pdb_tool} "$file" | perl -00 -pe 's/TER\nTER\n//' > "${dirname}/${pdb}_${mutated_chain}_${mutation}_${first_chain}.pdb""
        # echo "pdb_selchain -${second_chain_pdb_tool} "$file" | perl -00 -pe 's/TER\nTER\n//' > "${dirname}/${pdb}_${mutated_chain}_${mutation}_${second_chain}.pdb""
        mut_first_chain_pdb=${dirname}/${pdb}_${mutated_chain}_${mutation}_${first_chain}.pdb
        mut_second_chain_pdb=${dirname}/${pdb}_${mutated_chain}_${mutation}_${second_chain}.pdb
         
        pdb_selchain -${first_chain_pdb_tool} "$file" | perl -00 -pe 's/TER\nTER\n//' > "${mut_first_chain_pdb}"
        pdb_selchain -${second_chain_pdb_tool} "$file" | perl -00 -pe 's/TER\nTER\n//' > "${mut_second_chain_pdb}"

        # # Select the appropriate chain based on mutation
        # if [[ "${first}" == *"${mutation}"* ]]; then
        #     echo "Processing file: $file (chain $first)"
        #     pdb_selchain -${first} "$file" > "${dirname}/${mut_pdb}.pdb"
        # else
        #     echo "Processing file: $file (chain $second)"
        #     pdb_selchain -${second} "$file" > "${dirname}/${mut_pdb}.pdb"
        # fi
        
        # Clean up the PDB file by removing "TER" lines
        grep -v "TER" "${mut_first_chain_pdb}" > "${mut_first_chain_pdb}.tmp" && mv "${mut_first_chain_pdb}.tmp" "${mut_first_chain_pdb}"
        grep -v "TER" "${mut_second_chain_pdb}" > "${mut_second_chain_pdb}.tmp" && mv "${mut_second_chain_pdb}.tmp" "${mut_second_chain_pdb}"
        
    fi
done
