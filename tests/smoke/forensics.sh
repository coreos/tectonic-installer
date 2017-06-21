#!/usr/bin/env bash
set -x

echo -n "hostname: "
hostname

echo -n "master: "
cat /run/metadata/master
echo "
"

echo "ls /opt/tectonic:"
ls /opt/tectonic/
echo "
"
echo "Init assets:"
journalctl -u init-assets --no-tail | cat
echo "

"
echo "Bootkube:"
journalctl -u bootkube --no-tail | cat
echo "

"

echo "Tectonic:"
journalctl -u tectonic --no-tail | cat
echo "

"
