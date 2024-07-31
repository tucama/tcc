proc solvate_molecule {solvate_file psf pdb size} {
    if {![file exists "${solvate_file}.psf"]} {
        puts "generating solvated molecule pdb and psf"
        package require solvate 
        solvate "${psf}" "${pdb}" -t $size -o "${solvate_file}"
        mol delete all
    }
}
