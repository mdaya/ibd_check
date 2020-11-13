#!/bin/bash

plink_in_file=$1

plink --bfile $plink_in_file \
   --indep 50 5 5 
plink --bfile $plink_in_file \
   --extract plink.prune.in \
   --make-bed --out ${plink_in_file}_pruned

plink --bfile ${plink_in_file}_pruned \
   --genome 
