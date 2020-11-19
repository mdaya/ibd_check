#!/bin/bash

plink_bed_file=$1
window_size=$2
step_size=$3
vif_threshold=$4

plink_in_file=`sed 's/.bed//' $plink_bed_file`

plink --bfile $plink_in_file \
   --indep $window_size $step_size $vif_threshold 
plink --bfile $plink_in_file \
   --extract plink.prune.in \
   --make-bed --out ${plink_in_file}_pruned

plink --bfile ${plink_in_file}_pruned \
   --genome 
