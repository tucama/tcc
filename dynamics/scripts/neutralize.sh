#!/bin/bash

# Caminho para o diretório base onde estão os complexos
base_dir="$HOME/tcc/dynamics/1_min/"

# Encontrar todos os arquivos .pdb no diretório e subdiretórios
find "${1:-"$base_dir"}" -type f -name "*.pdb" | while read pdb_file; do
    # Nome do arquivo sem extensão
    base_name=$(basename "$pdb_file" .pdb)
    output_dir=$(dirname "$pdb_file")

    # Cria um arquivo temporário para o script tleap específico desse complexo
    tleap_template="$HOME/tcc/dynamics/scripts/amber.in"
    tleap_input="tleap_${base_name}.in"
    sed -e "s|__PDB_FILE__|$pdb_file|g" \
        -e "s|__OUTPUT_FILE__|$output_dir/$base_name|g" \
        $tleap_template > "$tleap_input"

    # Executa o tleap usando o script gerado
    tleap -f "$tleap_input"

    # Remove o arquivo tleap temporário
    rm "$tleap_input"
done
