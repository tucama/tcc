# command to produce this script for all pdbs.
# Requires Rust's fd find and sd sed
# fd "^.{4}\.pdb" -t f  -a -x cp automatize.tcl {//}/{/.}_auto.tcl && fd "^.{4}\.pdb" -t f -a -x sd "/home/tucamar/Documents/tcc/tcc-arthur/00_dataset/1emv/1emv_B_K97_A_B_final.pdb" {} {//}/{/.}_auto.tcl

# Get the input file path
set input_file "/home/tucamar/Documents/tcc/tcc-arthur/00_dataset/1emv/1emv_B_K97_A_B_final.pdb"
set filename [file rootname [file tail $input_file]]
set filedir [file dirname $input_file]
set pdb_file "${filename}_autopsf.pdb"
set psf_file "${filename}_autopsf.psf"
set solvate "${filename}_wb"
set noh_file "${filename}_noh.pdb"


# Removes hydrogens
mol new $input_file
set sel [atomselect top "protein and not hydrogen"]
$sel writepdb "${filedir}/${noh_file}"

# package require psfgen
# resetpsf
# topology $env(HOME)/Documents/charmmff/top_all36_prot.rtf
# pdbalias residue HIS HSE
# pdbalias residue HIE HSE
# pdbalias atom ILE CD1 CD
# segment U {pdb $noh_file}
# coordpdb $noh_file U
# guesscoord
# writepdb $pdb_file
# writepsf $psf_file

# USING AUTOPSF
package require autopsf
autopsf -psf "${psf_file}" -pdb "${noh_file}" -dir $filedir
# List all files starting with ".*_autopsf" in the source directory
set files [glob -nocomplain "./${filename}_autopsf*"]
# Move each autopsf file to the destination directory
foreach file $files {
    set dest_file "${filedir}/[file tail $file]"
    file rename $file $dest_file
}

# SOLVATE
package require solvate 
solvate "${filedir}/${psf_file}" "${filedir}/${pdb_file}" -t 5 -o "${filedir}/${solvate}"
mol delete all

#FIX ATOMs
set psf "${solvate}.psf"
set pdb "${solvate}.pdb"
set out "${solvate}.fix"

mol load psf $psf
mol addfile $pdb type pdb first 0 last -1 waitfor all
set allatoms [atomselect top all]
$allatoms set occupancy 0
$allatoms set beta 0
set group [atomselect top "protein"]
$group set beta 1
$allatoms writepdb $out

# Periodic cell calculation
mol new "${filedir}/${solvate}.psf"
mol addfile "${filedir}/${solvate}.pdb" type pdb
set wb_sel [atomselect top all] 
set minmax [measure minmax $wb_sel]
set min_x [lindex $minmax 0 0]
set max_x [lindex $minmax 1 0]
set min_y [lindex $minmax 0 1]
set max_y [lindex $minmax 1 1]
set min_z [lindex $minmax 0 2]
set max_z [lindex $minmax 1 2]

set cellbasisvector "cellBasisVector1 [expr {$max_x-$min_x}] 0 0\n"
append cellbasisvector "cellBasisVector2 0 [expr {$max_y-$min_y}] 0\n"
append cellbasisvector "cellBasisVector3 0 0 [expr {$max_z-$min_z}]\n"
set cellorigin "cellOrigin [expr {$min_x+($max_x-$min_x)/2}] [expr {$min_y+($max_y-$min_y)/2}] [expr {$min_z+($max_z-$min_z)/2}]"
set cell_block "$cellbasisvector$cellorigin"

# Function does not work, hardcoding...
# Creates new namd conf files
set namd_basefile "$env(HOME)/Documents/tcc/tcc-arthur/namd.conf"
set new_namd_conf_file "${filedir}/${solvate}.conf"

set file_content [list]
set file_in [open $namd_basefile r]
while {[gets $file_in line] >= 0} {
    # Check and replace specific lines
    if {[string match "structure*" $line]} {
        lappend file_content  "structure ${filedir}/${solvate}.psf"
    } elseif {[string match "coordinates*" $line]} {
        lappend file_content  "coordinates ${filedir}/${solvate}.pdb"
    } elseif {[string match "periodic_info*" $line]} {
        lappend file_content  "${cell_block}"
    } elseif {[string match "input_name*" $line]} {
        lappend file_content   "set inputname ${solvate}"
    } elseif {[string match "output_name_min*" $line]} {
        lappend file_content   "set outputname ${solvate}_min"
    } elseif {[string match "fixed_file" $line]} {
        lappend file_content   "fixedAtomsFile ${solvate}.fix"
    } else {
        lappend file_content $line
    }
}
close $file_in

# Write the modified content to the new file
set file_out [open $new_namd_conf_file w]
foreach line $file_content {
    puts $file_out $line
}
close $file_out
 
exit


