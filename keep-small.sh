#!/bin/bash

echo -e "Darktable Keep Smallest File Script\n"
options=$(getopt -l "debug,dry-run,ext1::,ext2::" -a -- "$@")
eval set -- "$options"

while true
do
    case "$1" in
        --debug)
            set -xv  # Set xtrace and verbose mode.
            ;;
        --dry-run)
            export dry_run=1
            ;;
        --ext1)
            export ext1=$2
            ;;
        --ext2)
            export ext2=$2
            ;;
        --)
            shift
            break
            ;;
    esac
    shift
done

#ext1 vs ext2
for file1 in $(find . -name "*.${ext1}" -print -type f -size +0c); do
    filename="${file1%.*}"
    extension="${file1##*.}"
    echo -e "\tAnalizing ${file1}"
done
