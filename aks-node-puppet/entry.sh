#!/bin/sh
set -e

echo "Copying run.sh and cron.pp to /node"
cp run.sh cron.pp /node

echo "Chrooting to /node and running run.sh"
chroot /node ./run.sh

echo "Cleaning up run.sh and cron.pp"
rm -rf /node/run.sh /node/cron.pp