proc extract_xyz {solvate} {
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
    return $minimized_xyz
}
