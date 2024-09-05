dynamic_dir="$HOME/Documents/tcc/dynamics"
mopac_dir="${dynamic_dir}/2_mopac"

fd . "${1:-$mopac_dir}" -e "pdb" -t f -x echo {.} | xargs -I {} bash -c 'echo -e "PM7 AUX LARGE ALLVECS VECTORS GEO-OK 1SCF MOZYME XYZ PL T=1D EPS=78.4 RSOLV=1.3 PDB CUTOFF=9.0 LET DISP(1.0)\n\n" | cat - {}.pdb > {}.tmp && mv {}.tmp {}.mop && rm {}.pdb'
