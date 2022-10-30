#!/usr/bin/env bash

set -eEuo pipefail

usage () {
    echo "Usage: $0 [OPTIONS...] SOURCEFILE"
    echo "Options:"
    echo "  -o OUTPUTFILE  name of the generated files;"
    echo "                 if the name contains a '@' it will"
    echo "                 be substituted with a counter, else the"
    echo "                 counter will be appended to the filename;"
    echo "                 defaults to 'tk01_@.xml'"
    echo "  -f NUMFILES    number of files to generate;"
    echo "                 defaults to 1"
    echo "  -a NUMARTICLES number of articles per file;"
    echo "                 defaults to 1"
    echo "  -h             show this help"
}

outputfile='tk01_@.xml'
numfiles=1
numarticles=1

while getopts "i:o:f:a:h" option; do
    case "$option" in
        o)
            outputfile="$OPTARG"
            ;;
        f)
            numfiles="$OPTARG"
            ;;
        a)
            numarticles="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift "$(( OPTIND - 1 ))"

if [[ "$#" -eq 0 ]]; then
    usage
    exit 1
fi
inputfile="$1"

if [[ "$outputfile" != *'@'* ]]; then
    outputfile="${outputfile}@"
fi

curr='13'
for (( i=1; i <= numfiles; i++ )); do
    output=${outputfile//@/$i}

    head -n 13 "$inputfile" > "$output"

    prev="$curr"
    curr="$(rg -nx '.*</items>.*' -r '' "$inputfile" -m $(( numarticles * i )) | tail -n 1 | cut -d':' -f1)"

    head -n "$curr" "$inputfile" | tail -n $(( curr - prev )) >> "$output"

    tail -n 2 "$inputfile" >> "$output"
done
