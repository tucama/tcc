topology ../01_min/toppar/top_all36_prot.rtf

segment SegA {pdb ../00_dataset/1a4y/1a4y_A_D435_A_final.pdb}
pdbalias atom ILE CD1 CD
coordpdb ../00_dataset/1a4y/1a4y_A_D435_A_final.pdb SegA

segment SegB {pdb ../00_dataset/1a4y/1a4y_A_D435_B_final.pdb}
coordpdb ../00_dataset/1a4y/1a4y_A_D435_B_final.pdb SegB

guesscoord

writepdb ../01_min/1a4y/1a4y_A_D435_A_B_final_psfgen.pdb
writepsf ../01_min/1a4y/1a4y_A_D435_A_B_final_psfgen.psf
