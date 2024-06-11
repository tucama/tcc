#!/bin/bash

# requires rusts rnr, fd and sd
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && source $HOME/.cargo/env && cargo install fd-find ripgrep sd

data_dir="$HOME/Documents/tcc/dynamics/0_dataset"
min_dir="$HOME/Documents/tcc/dynamics/1_min"
namd_conf="$HOME/Documents/tcc/dynamics/namd.conf"

rnr "_final" "" "$data_dir" -f -r
# Find all .pdb files
fd -a -e "pdb" . "${data_dir}" | while read -r file; do
    # Extract the file name
    file_name=$(basename "$file")
    
    pdb="${file_name:0:4}"
    # Extract the desired directory structure from the file name
    dir_name=$(echo "$file_name" | sed -E 's/^(.{4}_[^_]*_[^_]*)_.*/\1/')
    # Create the new directory structure
    new_dir="$min_dir/$pdb/$dir_name"
    mkdir -p "$new_dir"
    tcl_script="${new_dir}/${dir_name}_auto.tcl"
    
    # Copy the file to the new directory
    cp "$file" "$new_dir"
    cp "./prepare_pdbs.tcl" "${tcl_script}"
    sd "INPUT" "${new_dir}/${file_name}" "${tcl_script}" 
    sd "NAMD_CONF" "${namd_conf}" "${tcl_script}" 

    # vmd -dispdev text -e "${tcl_script}"
done

