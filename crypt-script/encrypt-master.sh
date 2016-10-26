#!/bin/bash
#
# file: encrypt-master
#
# Encrypts a folder using gpg2 AES256 cipher. The encrypted file is then 
# split into smaller pieces and placed in a subdirectory called archive. 
# The file can be reassembled and decrypted using the decrypt-master command. 
# 
# usage: ./encrypt-master -b "blocksize" "filename"  
# or     ./encrypt-master "filename"
#
command -v  gpg2 > /dev/null && echo "found gpg2"  || { echo "Install gpg2" exit 1;}
command -v tar > /dev/null && echo "found tar" || { echo "Install tar" exit 1;}
command -v split > /dev/null && echo "found split" || { echo "Install split" exit 1;}

if [ "$1" == "-b" ]; then
    echo "her"
    size="$2"
    file="$3"
    tar_file="$file.tar"
else 
    size="1000"
    file="$1"
    tar_file="$file.tar"
fi


if ! [[ "$size" =~ ^[0-9]+$ ]]; then
   echo "$size is an invalid block size"
   exit 1
fi

if [[ "$file" =~ ^- ]]; then
   echo "Invalid filename"
   exit 1
fi

if [ -d archive ]; then
    echo "Directory named archive already exists"
    exit 1
fi

mkdir archive

tar -cvzf $tar_file $file
if [ $? -ne 0 ]; then
    echo "Tar failed"
    rm "$tar_file"
    rm -r archive
    exit 1
fi

gpg2 --symmetric --cipher-algo AES256 $tar_file
if [ $? -ne 0 ]; then
    echo "gpg2 failed"
    rm "$tar_file"
    rm "$tar_file.gpg"
    rm -r archive
    exit 1
fi

split -b $size "$tar_file.gpg" ./archive/master_archive_
if [ $? -ne 0 ]; then
    echo "split failed"
    rm "$tar_file"
    rm "$tar_file.gpg"
    rm "master_archive_*"
    rm -r archive
    exit 1
fi     

rm "$tar_file"
rm "$tar_file.gpg"
cp encrypt-master archive
cp decrypt-master archive
