proc create_namd_conf {namd_basefile solvate cell_block} {
    puts "creating custom namd conf file"
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
    set file_out [open "${solvate}_min.conf" w]
    foreach line $file_content {
        puts $file_out $line
    }
    close $file_out
}
