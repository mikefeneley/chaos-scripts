#!/bin/bash 
#
# file: decrypt-master
#
# Decrypt a folder  that has been encrypted using the encrypt-master script.
# Encrypted file pieces must be in subdirectory named  archive. Folders 
# encrypted with encrypt-master are placed there by default.
#

command -v  gpg2 > /dev/null && echo "found gpg2"  || { echo "Install gpg2" exit 1;}
command -v tar > /dev/null && echo "found tar" || { echo "Install tar" exit 1;}
command -v split > /dev/null && echo "found split" || { echo "Install split" exit 1;}

cat ./archive/master_archive_* > ./archive/master.gpg

if [ $? -ne 0 ]; then
    echo "cat failed"
    rm ./archive/master.gpg
    exit 1
fi

gpg2 -o ./archive/master.tar --decrypt ./archive/master.gpg

if [ $? -ne 0 ]; then
    echo "decrypt with gpg2 failed"
    rm ./archive/master.gpg
    rm ./archive/master.tar
    exit 1
fi

tar -xzvf ./archive/master.tar

rm ./archive/master.tar
rm ./archive/master.gpg

if [ $? -ne 0 ]; then
    echo "tar failed"
    exit 1
fi

exit 0
