#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "$0 fw_filename"
    exit 1
fi

file_in="$1"
file_out_bin=${file_in}.bin

print_val ()
{
    val="$1"
    printf "0x%.2x" "$val" | xxd -r -p >> ${file_out_bin}
}

rm -f ${file_out_bin}

size=`cat ${file_in} | wc -w`

checksum=0
i=1
for val in `cat ${file_in}`; do
    val="0x$val"
    if [[ $i == $size ]]; then
	# Config_Fresh
	print_val 0x01
    elif [[ $i == $((size-1)) ]]; then
	# Config_Chksum
	checksum=$(( (~ checksum + 1) & 0xFF))
	print_val $checksum
    else
	checksum=$((checksum + val))
	print_val $val
    fi
    i=$((i+1))
done

echo "Wrote ${file_out_bin}"
