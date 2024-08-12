


proc create_mop_file {minimized_xyz filename} {
    set mop_file "${filename}.mop"
    if {![file exists "${mop_file}"]} {
        # Load the XYZ file into VMD
        mol new $minimized_xyz type xyz

        # Get the number of atoms
        set num_atoms [molinfo top get numatoms]

        # Open the MOP file for writing
        set output [open $mop_file w]

        # Write the MOPAC header
        puts $output "PM3\nTitle: Converted from XYZ file\n"

        # Loop over each atom to write atom data
        for {set i 0} {$i < $num_atoms} {incr i} {
                # Get atom type and coordinates
                set atom_type [atomselect top "index $i" get element]
                set coords [atomselect top "index $i" get {x y z}]

                # Extract coordinates
                set x [lindex $coords 0]
                set y [lindex $coords 1]
                set z [lindex $coords 2]

                # Write the atom line to the MOP file
                puts $output "$atom_type   $x  1  $y  1  $z  1"
        }
        close $output
    }
}
