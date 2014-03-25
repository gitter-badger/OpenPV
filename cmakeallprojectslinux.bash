#! /bin/bash

# Run cmake from all directories with a CMakeLists.txt,
# assuming MPI is in standard places

if test "${0%/*}" != "$0"
then
    wd="${0%/*}"
else
    wd="."
fi
# $wd is now the directory that this script is in
echo $wd

PV_DIR=$wd/../PetaVision
if test -n "$(echo "$1" | egrep '^-DPV_DIR=')"
then
    PV_DIR="$(echo "$1" | sed -e '1,$s/^-DPV_DIR=//')"
fi
if test -z "$(echo "$PV_DIR" | egrep '^/')"
then
    PV_DIR=$PWD/$PV_DIR
fi
echo "PetaVision directory set to $PV_DIR"

for proj in $(ls $wd/*/CMakeLists.txt | xargs -n 1 dirname)
do
    (cd $proj &&
     cmake -DCMAKE_BUILD_TYPE=Debug \
           -DPV_DIR=$PV_DIR &&
           make clean &&
           make)
done
