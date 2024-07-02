import math
import os
import re
import sys


def main():
    pdb_file_path = os.path.abspath(sys.argv[1])
    find_disulfide_bonds(pdb_file_path)


def find_disulfide_bonds(pdb_file_path):
    with open(pdb_file_path) as file:
        cys_residues = get_cys_res(file.readlines())

        paired_residues = set()
        for res1 in cys_residues:
            for res2 in cys_residues:
                if res1 != res2 and (res2[0], res1[0]) not in paired_residues:
                    distance = math.sqrt(
                        (res1[1] - res2[1]) ** 2
                        + (res1[2] - res2[2]) ** 2
                        + (res1[3] - res2[3]) ** 2
                    )
                    if 0 < distance < 3.5:
                        paired_residues.add((res1[0], res2[0]))
                        print(f"patch DISU $chain:{res1[0]} $chain:{res2[0]}")


def get_cys_res(lines):
    cys_residues = []
    for line in lines:
        if "ATOM" in line and ("SG  CYS" in line or "SG  CYX" in line):
            chain = re.findall(r"[a-zA-Z]+", str(line.split()[4]))[0]
            residue_number = line.split()[5]
            if len(residue_number) > 3:
                residue_number = re.findall(r"\d+", str(line.split()[4]))[0]
            x_coord = float(line[30:38])
            y_coord = float(line[38:46])
            z_coord = float(line[46:54])
            cys_residues.append((residue_number, x_coord, y_coord, z_coord, chain))
    return cys_residues


if __name__ == "__main__":
    main()
