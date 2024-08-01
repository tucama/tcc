# command to produce this script for all pdbs -> automatize.sh

# GET THE INPUT FILE PATH
set input_file [lindex $argv 0]
set filename [file rootname [file tail $input_file]]
set filedir [file dirname $input_file]
set pdb_file "${filedir}/${filename}_psfgen.pdb"
set psf_file "${filedir}/${filename}_psfgen.psf"
set solvate "${filedir}/${filename}_wb"
set new_namd_conf_file "${solvate}_min.conf"

set homedir "$env(HOME)"
set dynamic_dir "$homedir/Documents/tcc/dynamics"
set script_dir "${dynamic_dir}/scripts"
set topology_file "${dynamic_dir}/charmmff/top_all36_prot.rtf"
set ssbond_script "${script_dir}/ssbond.py"
set namd_conf "${script_dir}/namd.conf"

source "${script_dir}/psfgen.tcl"
create_psf "${input_file}" "${topology_file}" "${ssbond_script}"

source "${script_dir}/solvate.tcl"
solvate_molecule "${solvate}" "${psf_file}" "${pdb_file}" "10"
add_ions "${solvate}"

#FIX ATOMS
source "${script_dir}/fix_atoms.tcl"
fix_atoms "${solvate}"

if {![file exists $new_namd_conf_file]} {
    source "${script_dir}/periodic_cell.tcl"
    set cell_block [calculate_periodic_cell "$solvate"]

    source "${script_dir}/create_namd_conf.tcl"
    create_namd_conf "${namd_conf}" "${solvate}" "${cell_block}"
}

# # RUN NAMD
# # Maybe not run in the script, seems sketchy
# if {![file exists "${solvate}_min.log"]} {
#     puts "running namd minimization"
#     exec namd3 +auto-provision $new_namd_conf_file > "${solvate}_min.log"
# }
#
# # EXTRACT MINIMIZED STRUCTURE INTO PDB
# source "${script_dir}/minimized_xyz.tcl"
# set minimized_xyz [extract_xyz "${solvate}"]
#
# source "${script_dir}/create_mop_file.tcl"
# create_mop_file "${minimized_xyz}" "${filename}"

puts "removing molecules and ending programm"
mol delete all
exit
