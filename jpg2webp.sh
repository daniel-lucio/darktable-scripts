#!/bin/bash

echo -e "Darktable JPEG to WEBP Script\n"

#ext1 vs ext2
for file1 in $(find . -name "*.jpg" -print -type f -size +0c); do
    filename="${file1%.*}"
    extension="${file1##*.}"
    echo -e "\tConverting ${file1}"
    #convert
    cwebp -q 95 "${file1}" -o ${filename}.webp
    #copy the metadata
    exiftool -TagsFromFile "${file1}" ${filename}.webp
    #keep the timestamp
    touch -d @$(stat -c "%Y" "${file1}") ${filename}.webp
done
rm -f *_original
