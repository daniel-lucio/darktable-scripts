#!/bin/bash

function setDefaults(){
    if [ .$dt_dir = .'' ]; then
        export dt_dir=$(eval echo ~$USER)/.config/darktable
    fi
}

echo -e "Darktable Not Zero Script\n"
options=$(getopt -l "debug,dt-dir:,dry-run" -a -- "$@")
eval set -- "$options"

while true
do
    case "$1" in
        --debug)
            set -xv  # Set xtrace and verbose mode.
            ;;
        --dt-dir)
            export dt_dir=$2
            ;;
        --dry-run)
            export dry_run=1
            ;;
        --)
            shift
            break
            ;;
    esac
    shift
done

setDefaults

OLD_IFS=${IFS}
IFS=$'\t\n'
for film_roll in $(sqlite3 "${dt_dir}/library.db" "SELECT id,folder FROM film_rolls"); do
    roll_id=$(echo -n ${film_roll} | cut -d'|' -f 1)
    roll_folder=$(echo -n ${film_roll} | cut -d'|' -f 2)

    echo -e "Inspecting ${roll_folder}\t${roll_id}"
    for zero_file in $(find ${roll_folder} -type f -size 0); do
        filename="${zero_file%.*}"              # includes absolute path
        extension="${zero_file##*.}"            # last extension
        echo -e "\tZero file ${zero_file}"
#        echo -e "\t\t${filename}\t${extension}"

        if [ .${extension,,} = ."xmp" ]; then
            #it is a development file
            roll_file={$filename}
            basename=$(basename ${filename})       # only filename
        else
            roll_file=${zero_file}
            basename=$(basename ${zero_file})       # only filename
        fi

        query="DELETE FROM images WHERE film_id=${roll_id} AND filename='${basename}'"
        if [ .$dry_run = .'1' ]; then
            echo -e "\tDry run: ${query}\n"
        else
            sqlite3 ${dt_dir}/library.db "${query}"
            rm -f "${zero_file}"
        fi
    done
done
IFS=${OLD_IFS}

# SELECT images.id, images.filename, film_rolls.folder, film_rolls.folder || '/' || images.filename AS full_name FROM images INNER JOIN film_rolls ON images.film_id = film_rolls.id WHERE full_name='/mnt/vault/Photos/CANON/R5m2/100EOSR5/1P8A2293.CR3'")
