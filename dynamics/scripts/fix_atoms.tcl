proc fix_atoms {solvate} {
    puts "generating fixed atom files"
    set psf "${solvate}.psf"
    set pdb "${solvate}.pdb"
    set fix_file "${solvate}.fix"

    if {![file exists "$fix_file"]} {
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
}
