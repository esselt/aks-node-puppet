#!/bin/sh
set -e

echo "Copying run.sh to /node"
cp run.sh /node

echo "Chrooting to /node and running run.sh"
chroot /node ./run.sh

echo "Cleaning up run.sh"
rm -rf /node/run.sh