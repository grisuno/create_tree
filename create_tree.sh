#!/bin/bash

# Verifica si se pasó un archivo como argumento
if [ $# -ne 1 ]; then
    echo "Uso: $0 <archivo_estructura.txt>"
    exit 1
fi

input_file="$1"

# Verifica si el archivo existe
if [ ! -f "$input_file" ]; then
    echo "Error: El archivo '$input_file' no existe"
    exit 1
fi

# Función para contar el nivel de indentación (basado en │ y espacios)
count_indent() {
    local line="$1"
    local count=0
    # Contamos los caracteres de indentación (│, ├──, └── y espacios)
    while [[ "$line" =~ ^[│\ ├└─]+ ]]; do
        line="${line:1}"
        ((count++))
    done
    echo "$count"
}

# Directorio base inicial
base_dir=""

# Lee el archivo línea por línea
while IFS= read -r line; do
    # Ignora líneas vacías
    [ -z "$line" ] && continue

    # Obtiene el nivel de indentación
    indent=$(count_indent "$line")

    # Extrae el nombre del elemento (directorio o archivo)
    # Elimina los caracteres de árbol y comentarios
    name=$(echo "$line" | sed 's/^[│\ ├└─]*//' | sed 's/\s*#.*$//')

    # Determina si es directorio (termina en /) o archivo
    if [[ "$name" =~ /$ ]]; then
        # Es un directorio
        name="${name%/}"  # Elimina la barra final
        dir_path="$base_dir/$name"
        mkdir -p "$dir_path"
        echo "Creando directorio: $dir_path"
        # Actualiza base_dir para este nivel
        if [ $indent -eq 0 ]; then
            base_dir="$name"
        else
            base_dir=$(echo "$base_dir" | cut -d'/' -f1-$((indent/2+1)))
            base_dir="$base_dir/$name"
        fi
    else
        # Es un archivo
        file_path="$base_dir/$name"
        mkdir -p "$(dirname "$file_path")"  # Crea directorios padre si no existen
        touch "$file_path"
        echo "Creando archivo: $file_path"
    fi
done < "$input_file"

echo "Estructura de directorios y archivos creada exitosamente"
