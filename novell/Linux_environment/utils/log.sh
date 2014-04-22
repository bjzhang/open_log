#!/bin/bash

name=$1
shift
param="$*"
current=`date +%Y%m%d_%H%M_%S`
filename=log_${current}_`echo $name | sed "s/\//_/g"`.txt
cmdline="$name $param"
echo "###################START###################" >> $filename
echo "test start at $current. hostname: `hostname`" >> $filename
echo "uname -a: <`uname -a`>" >> $filename
echo "command line: <$cmdline>" >> $filename
echo "#################LOG START#################" >> $filename
$name $param 2>&1 | tee $filename -a
echo "####################END####################" >> $filename
