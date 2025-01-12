#!/bin/bash


# # Directory containing the MOPAC input files (.mop)
# dyn_dir="$HOME/Documents/tcc/dynamics"
# mopac_dir="${dyn_dir}/2_mopac"

num_threads=$(nproc)

run_mopac() {
    local input_file="$1"
    local base_name=$(basename "$input_file" .mop)
    cd $(dirname $input_file)

    echo "Running MOPAC on $base_name.mop..."

    # Run MOPAC
    mopac "$input_file"
    if [[ -f "${input_file%.*}.arc" ]]; then
        gzip "${input_file%.*}.aux" -f
    else
        rm "${input_file%.*}.aux" "${input_file%.*}.out" "${input_file%.*}.end" "${input_file%.*}.log" 

    fi


}

fd . "${1:-.}" -e mop | while read -r file; do
    if [[ ! -f "${file%.*}.arc" ]] ; then
        while (( $(jobs -r | wc -l) >= num_threads )); do
            # Wait for a slot to become available
            sleep 1
        done

        # Run MOPAC in the background
        if [ -f "mopac" ]; then
            run_mopac "$file" &
        fi

    fi
done

wait

echo "All calculations are complete."

