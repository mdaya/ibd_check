#!/bin/bash

plink_in_file=$1
window_size=$2
step_size=$3
vif_threshold=$4

plink --bfile $plink_in_file \
   --indep $window_size $step_size $vif_threshold 
plink --bfile $plink_in_file \
   --extract plink.prune.in \
   --make-bed --out ${plink_in_file}_pruned

plink --bfile ${plink_in_file}_pruned \
   --genome 
