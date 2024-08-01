proc calculate_periodic_cell {solvate} {
    # PERIODIC CELL CALCULATION
    puts "==========================================================="
    puts "calculating periodic cell"
    puts "==========================================================="

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

    set cellbasisvector "cellBasisVector1 [expr {$max_x-$min_x}] 0.0 0.0\n"
    append cellbasisvector "cellBasisVector2 0.0 [expr {$max_y-$min_y}] 0.0\n"
    append cellbasisvector "cellBasisVector3 0.0 0.0 [expr {$max_z-$min_z}]\n"
    set cellorigin "cellOrigin [expr {$min_x+($max_x-$min_x)/2}] [expr {$min_y+($max_y-$min_y)/2}] [expr {$min_z+($max_z-$min_z)/2}]"
    set cell_block "$cellbasisvector$cellorigin"

    return $cell_block
}
