#!/bin/bash

# requires rusts rnr, fd and sd
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && source $HOME/.cargo/env && cargo install fd-find ripgrep sd

dynamic_dir="$HOME/Documents/tcc/dynamics"
data_dir="${dynamic_dir}/0_dataset"
top_file="${dynamic_dir}/charmmff/top_all36_prot.rtf"
min_dir="${dynamic_dir}/1_min"
script_dir="${dynamic_dir}/scripts"
ssbond_script="${script_dir}/ssbond.py"
namd_conf="${script_dir}/namd.conf"

rnr "_final" "" "$data_dir" -f -r --no-dump
# Find all .pdb files
fd -a -e "pdb" . "${data_dir}" | while read -r file; do
    # Extract the file name
    file_name=$(basename "$file")
    
    pdb="${file_name:0:4}"
    # Extract the desired directory structure from the file name
    dir_name=$(echo "$file_name" | sed -E 's/^(.{4}_[^_]*_[^_]*)_.*/\1/')

    # Create the new directory structure
    out_dir="$min_dir/$pdb/$dir_name"
    out_file="${out_dir}/${file_name}"
    mkdir -p "$out_dir"
    tcl_script="${out_dir}/${dir_name}_auto.tcl"
    
    # Copy the file to the new directory
    cp "$file" "$out_file"
    cp "${script_dir}/prepare_pdbs.tcl" "${tcl_script}"
    sd "INPUT" "${out_file}" "${tcl_script}" 
    sd "SSBOND" "set ssbond_script ${ssbond_script}" "${tcl_script}" 
    sd "TOPOLOGY" "topology ${top_file}" "${tcl_script}" 
    sd "NAMD_CONF" "${namd_conf}" "${tcl_script}" 
done

