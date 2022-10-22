#!/usr/bin/env bash

set -eEuo pipefail

index_path="$1"
tables_dir="$(dirname "$index_path")/tables"
dest_dir_index="${index_path%/*/*}/csv"
dest_path_index="$dest_dir_index/Index.csv"
dest_dir_tables="$dest_dir_index/tables"

format_index () {
    mkdir -p "$dest_dir_index"

    awk -F '&nbsp;' '/&nbsp;/ { print $2 }' "$index_path" > "$dest_path_index"

    sed -i 's_<a[^>]*>\(.*\)</a>_\1_' "$dest_path_index"

    vim "$dest_path_index" -c 'set noswf bh=delete noet | let @a="$a;\<Esc>gJ" | let @b="3@aj" | let @c="dd10000@b" | argdo normal @c | argdo x'
}

format_tables () {
    mkdir -p "$dest_dir_tables"

    for table in "$tables_dir"/*; do
        filename="$(basename "${table%htm}")"
        awk -F '&nbsp;' '/&nbsp;/ { print $2 }' "$table" > "$dest_dir_tables/${filename}csv";
    done

    vim "$dest_dir_tables"/*.csv -c 'set noswf bh=delete noet | let @a="$a;\<Esc>gJ" | let @b="7@aj" | let @c="d6j10000@b" | argdo normal @c | argdo x'

    sed -i 's/\t\(\tX?\)$/\t-\1/' "$dest_dir_tables"/*.csv
}

format_index
format_tables
