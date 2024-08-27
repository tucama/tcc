dynamic_dir="$HOME/Documents/tcc/dynamics"
mopac_dir="${dynamic_dir}/2_mopac"
mopac_par="PM7 AUX LARGE MOZYME PDB ALLVECS VECTORS EPS=78.4 SCF"

fd . "${mopac_dir}" -e "pdb" -t f -x echo {.} | xargs -I {} bash -c 'echo -e "${mopac_dir}\n\n" | cat - {}.pdb > {}.tmp && mv {}.tmp {}.mop && rm {}.pdb'
