#!/bin/bash

# requires rusts rnr, fd and sd
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && source $HOME/.cargo/env && cargo install fd-find ripgrep sd

dynamic_dir="$HOME/Documents/tcc/dynamics"
data_dir="${dynamic_dir}/0_dataset"
min_dir="${dynamic_dir}/1_min"
vmd_prepare="${dynamic_dir}/scripts/vmd_prepare-test.tcl"

rnr "_final" "" "${data_dir}" -f -r --no-dump
# Find all .pdb files
echo "creating min dir"

fd -a -e "pdb" . "${data_dir}" | while read -r file; do
    # Extract the file name
    file_name=$(basename "$file")
    
    pdb="${file_name:0:4}"

    # Create the new directory structure
    out_dir="$min_dir/$pdb/${file_name%.*}"
    out_file="${out_dir}/${file_name}"
    
    # Copy the file to the new directory
    if [ ! -f "${out_file}" ] ; then
        echo "==================================================================="
        echo "running molecule ${out_file}"
        echo "==================================================================="
        mkdir -p "${out_dir}"
        cp "${file}" "${out_file}"
    fi
done

fd -a -e "pdb" . "${min_dir}" | while read -r file; do
    dir=$(dirname ${file})
    cd $dir
    if [[ $(fd "wb" "${dir}" 2>/dev/null) ]]; then
        echo "continuing"
        continue
    fi

    if [[ ! "$file_name" =~ chain ]] && [[ ! "$file_name" =~ psfgen ]] ; then
        echo "running vmd_prepare files for ${file}"
        vmd -dispdev text -e "${vmd_prepare}" -args "${file}" &
    fi
done
