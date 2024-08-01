proc solvate_molecule {solvate_file psf pdb size} {
    if {![file exists "${solvate_file}.psf"]} {
        puts "==========================================================="
        puts "generating solvated molecule pdb and psf"
        puts "==========================================================="

        package require solvate 
        solvate "${psf}" "${pdb}" -t $size -o "${solvate_file}"
        mol delete all
    }
}

proc add_ions {solvate_file} {
    if {![file exists "${solvate_file}.psf"]} {
        puts "==========================================================="
        puts "adding ions to waterbox"
        puts "==========================================================="
         # Load structure
        mol new "${solvate_file}.psf"
        mol addfile "${solvate_file}.pdb"

        # Load autoionize package
        package require autoionize

        # Neutralize the system
        autoionize -psf "${solvate_file}.psf" -pdb "${solvate_file}.pdb" -o "${solvate_file}" -neutralize -nion Na+ 0.15

        # Save the new structure
        set sel [atomselect top all]
        $sel writepdb "${solvate_file}.pdb"
        $sel writepsf "${solvate_file}.psf"   

        mol delete all
    }
}
