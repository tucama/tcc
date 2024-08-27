dynamic_dir="$HOME/Documents/tcc/dynamics"
mopac_dir="${dynamic_dir}/2_mopac"
dir="${1:-$mopac_dir}"

fd . "${dir}" -e "pdb" -t f -x echo {.} | xargs -I {} bash -c 'echo -e "PM7 AUX LARGE MOZYME PDB ALLVECS VECTORS EPS=78.4 1SCF\n\n" | cat - {}.pdb > {}.tmp && mv {}.tmp {}.mop && rm {}.pdb'
