# command to produce this script for all pdbs -> automatize.sh

# GET THE INPUT FILE PATH
set input_file "INPUT"
set filename [file rootname [file tail $input_file]]
set filedir [file dirname $input_file]
set pdb_file "${filedir}/${filename}_psfgen.pdb"
set psf_file "${filedir}/${filename}_psfgen.psf"
set solvate "${filedir}/${filename}_wb"
set new_namd_conf_file "${filedir}/${filename}_min.conf"
SSBOND


if {![file exists $psf_file]} {
    # GENERATE PSF FILES
    # USING MANUAL PSFGEN
    package require psfgen
    resetpsf
    pdbalias residue HIS HSE
    pdbalias residue HIE HSE
    pdbalias residue CYX CYS
    pdbalias residue CIS CYS
    pdbalias residue HIP HSP
    pdbalias residue HID HSD
    pdbalias atom ILE CD1 CD
    TOPOLOGY
    puts "generating psf files"
    mol new $input_file
    set protein [atomselect top "protein and not hydrogen"]
    set chains [lsort -unique [$protein get pfrag]]

    foreach chain $chains {
        set sel [atomselect top "pfrag $chain"]
        set chain_file "${filedir}/${filename}_chain_${chain}.pdb"
        $sel writepdb ${chain_file}
    }

    foreach chain $chains {
        set chain_file "${filedir}/${filename}_chain_${chain}.pdb"
        set disu_patch [exec python3 "$ssbond_script" "$chain_file"] 
        segment "$chain" {pdb $chain_file}
        eval $disu_patch
        coordpdb $chain_file "$chain"
    }
    puts "guessing"
    guesscoord
    writepdb $pdb_file
    writepsf $psf_file
}

# SOLVATE
if {![file exists "${solvate}.psf"]} {
    puts "generating solvated molecule pdb and psf"
    package require solvate 
    solvate "${psf_file}" "${pdb_file}" -t 5 -o "${solvate}"
    mol delete all
}

#FIX ATOMS
if {![file exists "${solvate}.fix"]} {
    puts "generating fixed atom files"
    set psf "${solvate}.psf"
    set pdb "${solvate}.pdb"
    set fix_file "${solvate}.fix"

    mol load psf $psf
    mol addfile $pdb type pdb first 0 last -1 waitfor all
    set allatoms [atomselect top all]
    $allatoms set occupancy 0
    $allatoms set beta 0

    # fix only protein
    set group [atomselect top "protein"]
    $group set beta 1
    $allatoms writepdb $fix_file
}
if {![file exists $new_namd_conf_file]} {
    # PERIODIC CELL CALCULATION
    puts "calculating periodic cell"
    mol new "${solvate}.psf"
    mol addfile "${solvate}.pdb" type pdb
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
    # Get the last frame of the minimization
    set last_frame [molinfo top get numframes]
    incr last_frame -1

    append cellbasisvector "cellBasisVector3 0 0 [expr {$max_z-$min_z}]\n"
    set cellorigin "cellOrigin [expr {$min_x+($max_x-$min_x)/2}] [expr {$min_y+($max_y-$min_y)/2}] [expr {$min_z+($max_z-$min_z)/2}]"
    set cell_block "$cellbasisvector$cellorigin"

    # INSERT SPECIFIC INFO INTO NAMD CONF
    set namd_basefile "NAMD_CONF"
    set file_content [list]
    set file_in [open $namd_basefile r]
    while {[gets $file_in line] >= 0} {
        # Check and replace specific lines
        # Ta feio pois nao sei tcl
        # TODO redo this using regex maybe
        if {[string match "structure*" $line]} {
            lappend file_content  "structure ${solvate}.psf"
        } elseif {[string match "coordinates*" $line]} {
            lappend file_content  "coordinates ${solvate}.pdb"
        } elseif {[string match "periodic_info*" $line]} {
            lappend file_content  "${cell_block}"
        } elseif {[string match "input_name*" $line]} {
            lappend file_content   "inputname ${solvate}"
        } elseif {[string match "output_name*" $line]} {
            lappend file_content   "outputname ${solvate}_min"
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
}

# RUN NAMD
# Maybe not run in the script, seems sketchy
if {![file exists "${solvate}_min.log"]} {
    puts "running namd minimization"
    exec namd3 +auto-provision $new_namd_conf_file > "${solvate}_min.log"
}

# EXTRACT MINIMIZED STRUCTURE INTO PDB
set dcd_file "${solvate}_min.dcd"
set minimized_xyz "${solvate}_minimized.xyz"
if {![file exists $minimized_xyz]} {
    puts "generating minimized structure xyz"
    # Load the structure and trajectory files
    mol new "${solvate}.psf" type psf
    mol addfile $dcd_file type dcd first 0 last -1 step 1 waitfor all

    # Go to the last frame
    animate goto [expr {[molinfo top get numframes] - 1}]

    # Write the minimized structure to a xyz file
    set sel [atomselect top protein]
    $sel writexyz $minimized_xyz
}

exit
