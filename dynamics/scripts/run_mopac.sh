#!/bin/bash

# Directory containing the MOPAC input files (.mop)
dyn_dir="$HOME/Documents/tcc/dynamics"
mopac_dir="${dyn_dir}/2_mopac"
default="."
pattern="${1:-$default}"

# Function to run MOPAC and handle compression
run_mopac() {
    local input_file="$1"
    local base_name=$(basename "$input_file" .mop)

    echo "Running MOPAC on $base_name.mop..."

    # Run MOPAC in the background
    mopac "$input_file" &

    # Get the PID of the MOPAC process
    local mopac_pid=$!

    # Wait for MOPAC to finish
    wait $mopac_pid

    echo "MOPAC job for $base_name.mop completed."
    if [[ ! -f "${mopac_dir}/mopac.aux.zip" ]]; then
        zip "$mopac_dir/mopac.aux.zip" "${input_file%.*}.aux"
    else
        # Compress the .aux file into a .zip archive using update mode (-u)
        zip -u "$mopac_dir/mopac.aux.zip" "${input_file%.*}.aux"
    fi

    echo "Updated $mopac_dir/mopac.aux.zip with  ${input_file%.*}.aux"
}

pid=()
# Loop through each .mop file in the input directory and run them in the background
fd "${pattern}" "${mopac_dir}" -e mop | while read -r file; do
    if [[ ! -f "${file%.*}.arc" ]] ; then
        run_mopac "$file" &
        pids+=($!)
    fi
done

for pid in "${pids[@]}"; do
    wait $pid
done

echo "All calculations are complete."

