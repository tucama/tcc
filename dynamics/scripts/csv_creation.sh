#! /usr/bin/bash

dir="/home/tucamar/tcc/gerd/"

# mutation_regex="[1-9a-z]{4}_[A-Za-z]{1,}_[1-9A-Z]{2,}"
complex_pdb_regex="[1-9a-z]{4}_[A-Z]+_[A-Z0-9]+_[A-Z]+_[A-Z]+.pdb$"
complex_chains_regex="_([A-Z]{1,}_[A-Z]{1,}).pdb$"
mutation_chain_regex="[0-9a-z]{4}_([A-Z]{1})_[A-Z0-9]{1,}"
mutation_regex="[0-9a-z]{4}_[A-Z]{1}_([A-Z0-9]{1,})"


fd ${complex_pdb_regex} $dir -a -t f -e "pdb" | while read -r file; do
    # Extract the filename from the full path
    
    complex_dir=$(dirname "$file")
    complex_pdb=$(basename "$file" .pdb)
    complex_pdb_file=$(basename "$file")
    pdb=${complex_pdb:0:4}

    rslrd_complex_mut="${complex_pdb}.rslrd"
    mutation_chain=$(echo "$complex_pdb"|  perl -ne 'print "$1\n" if /[0-9a-z]{4}_([A-Z]{1})_[A-Z0-9]{1,}/' )
    mutation=$(echo "$complex_pdb"|  perl -ne 'print "$1\n" if /[0-9a-z]{4}_[A-Z]{1}_([A-Z0-9]{1,})/' )

    chains=$(echo "$complex_pdb" | perl -ne 'if (/_([A,B]+)_([B,C,D,E]+)$/) { print "$1 $2\n"; }')
    first=$(echo "$chains" | awk '{print $1}')
    second=$(echo "$chains" | awk '{print $2}')

    pdb_complex_wt="${pdb}_wt_${first}_${second}.pdb"
    rslrd_complex_wt="${pdb}_wt_${first}_${second}.rslrd"

    pdb_p1_wt="${pdb}_wt_${first}.pdb"
    rslrd_p1_wt="${pdb}_wt_${first}.rslrd"

    pdb_p2_wt="${pdb}_wt_${second}.pdb"
    rslrd_p2_wt="${pdb}_wt_${second}.rslrd"

    pdb_p1_mut="${pdb}_${mutation_chain}_${mutation}_${first}.pdb"
    rslrd_p1_mut="${pdb}_${mutation_chain}_${mutation}_${first}.rslrd"

    pdb_p2_mut="${pdb}_${mutation_chain}_${mutation}_${second}.pdb"
    rslrd_p2_mut="${pdb}_${mutation_chain}_${mutation}_${second}.rslrd"

    csv_data="file_rslrd,file_pdb,type,pdb_code,mutation,chain
    ${rslrd_complex_mut},${complex_pdb_file},P_P,${pdb},${mutation},${mutation_chain}
    ${rslrd_p1_mut},${pdb_p1_mut},P,${pdb},${mutation},${mutation_chain}
    ${rslrd_p2_mut},${pdb_p2_mut},P,${pdb},${mutation},${mutation_chain}
    ${rslrd_complex_wt},${pdb_complex_wt},P_P,${pdb},wt,${mutation_chain}
    ${rslrd_p1_wt},${pdb_p1_wt},P,${pdb},wt,${mutation_chain}
    ${rslrd_p2_wt},${pdb_p2_wt},P,${pdb},wt,${mutation_chain}"

    csv_file="${complex_dir}/molecs_file_${complex_pdb}.csv"
    echo "$csv_data"  | sed 's/^[[:space:]]*//'  > $csv_file
    # echo "$csv_data"  | sed 's/^[[:space:]]*//' 
    # echo
 

done
