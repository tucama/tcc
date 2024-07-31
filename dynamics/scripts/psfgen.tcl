proc create_psf {input_file topology_file ssbond_script} {
    set filename [file rootname [file tail $input_file]]
    set filedir [file dirname $input_file]
    set pdb_file "${filedir}/${filename}_psfgen.pdb"
    set psf_file "${filedir}/${filename}_psfgen.psf"

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
        topology $topology_file
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
}
