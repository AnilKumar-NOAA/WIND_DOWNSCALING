#!/usr/bin/env bash
cwd=$(pwd)
cd $(dirname "$0")
file=$1
dir=$2
if [ "${file:0:1}" != "/" ]; then
    file=$cwd/$1
fi
if [ "${dir:0:1}" != "/" ]; then
    dir=$cwd/$2
fi
export PYTHONPATH=src
python convert_geotiff.py $file $dir $3 $4
