#!/bin/bash

function showHelp() {
cat << EOF
Usage: ./coolpbx.sh

-h,     -help,          --help                          Display help
-v,     -verbose,       --verbose                               Run script in verbose mode. Will print out each step of execution.
-d,     -debug,         --debug                                 Display debug information.

                        --source=XXXX                           The initial directory, by default is .
                        --destination=XXXX                      The destination directory, by default is .
                        --vendor=XXX                            Only process this vendor.
EOF
}

function setDefaults() {
        if [ .$source = .'' ]; then
                export source='.'
        fi
        if [ .$destination = .'' ]; then
                export destination='.'
        fi
        if [ .$vendor = .'' ]; then
                export vendor='*'
        fi
}

options=$(getopt -l "debug,help,verbose,source:,destination:,vendor:" -o "dhv" -a -- "$@")
eval set -- "$options"

while true
do
        case "$1" in
                -d|--debug)
                        set -xv  # Set xtrace and verbose mode.
                        ;;
                -h|--help)
                        showHelp
                        exit 0
                        ;;
                -v|--verbose)
                        export verbose=1
                        ;;
                --source)
                        export source=$2
                        ;;
                --destination)
                        export destination=$2
                        ;;
                --vendor)
                        export vendor=$2
                        ;;
                --)
                        shift
                        break
                        ;;
        esac
        shift
done
setDefaults

find ${source} -type f \( -name "*.CR2" -o -iname "*.CR3" -o -iname "*.DNG"  \) -print0 | while IFS= read -r -d '' file
do
echo $file
model=$(exiftool -s3 -Model "${file}")
make=$(exiftool -s3 -Make "${file}")
if [ .$verbose = .'1' ]; then
    echo $model
    echo $make
fi
if [[ "$vendor" == "*" || "$make" == "$vendor" ]]; then
    echo rsync -avhW "${file}" "${destination}${make}/${model}"
    rsync -avhW "${file}" "${destination}${make}/${model}"
fi
done
