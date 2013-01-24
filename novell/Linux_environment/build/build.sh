#!/bin/bash

name=$1
shift
param=$*
filename=log_`date +%Y%m%d_%H%M_%S`_`echo $name | sed "s/\//_/g"`
cmdline="$name $param"
echo $cmdline > $filename
$name $param 2>&1 | tee $filename -a
