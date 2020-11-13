#!/bin/bash

study1_plink_bed_file=$1
study2_plink_bed_file=$2
min_maf=$3
min_geno=$4
study1_plink_in_prefix=`echo $study1_plink_bed_file | sed 's/.bed//' | sed 's/.BED//'` 
study2_plink_in_prefix=`echo $study2_plink_bed_file | sed 's/.bed//' | sed 's/.BED//'` 
study1_plink_prefix=`basename $study1_plink_in_prefix` 
study2_plink_prefix=`basename $study2_plink_in_prefix` 

#Clean the data sets
bash /home/analyst/clean_data_set.sh $study1_plink_in_prefix $study1_plink_prefix
bash /home/analyst/clean_data_set.sh $study2_plink_in_prefix $study2_plink_prefix

#Get a list of common markers
cat ${study1_plink_prefix}_clean.bim ${study2_plink_prefix}_clean.bim | awk '{print $2}' | sort | uniq -d > ${study1_plink_prefix}_${study1_plink_prefix}_common_snps.txt
plink --bfile ${study1_plink_prefix}_clean \
   --extract ${study1_plink_prefix}_${study1_plink_prefix}_common_snps.txt \
   --make-bed --out ${study1_plink_prefix}_common
plink --bfile ${study2_plink_prefix}_clean \
   --extract ${study1_plink_prefix}_${study1_plink_prefix}_common_snps.txt \
   --make-bed --out ${study2_plink_prefix}_common

#First merge attempt
plink --bfile ${study1_plink_prefix}_common \
   --bmerge ${study2_plink_prefix}_common.bed ${study2_plink_prefix}_common.bim ${study2_plink_prefix}_common.fam \
   --make-bed --out ${study1_plink_prefix}_${study2_plink_prefix}_merged1

#Flip SNPs where necessary
if [ -e "${study1_plink_prefix}_${study2_plink_prefix}_merged1-merge.missnp" ]
then
   plink --bfile ${study2_plink_prefix}_common \
      --flip ${study1_plink_prefix}_${study2_plink_prefix}_merged1-merge.missnp \
      --make-bed --out ${study2_plink_prefix}_common_flipped
   plink --bfile ${study1_plink_prefix}_common \
      --bmerge ${study2_plink_prefix}_common_flipped.bed ${study2_plink_prefix}_common_flipped.bim ${study2_plink_prefix}_common_flipped.fam \
      --make-bed --out ${study1_plink_prefix}_${study2_plink_prefix}_merged2
else
   plink --bfile ${study1_plink_prefix}_${study2_plink_prefix}_merged1 --make-bed --out ${study1_plink_prefix}_${study2_plink_prefix}_merged2
fi

#Exclude allele mismatch SNPs
if [ -e "${study1_plink_prefix}_${study2_plink_prefix}_merged2-merge.missnp" ]
then
   plink --bfile ${study1_plink_prefix}_common \
      --exclude ${study1_plink_prefix}_${study2_plink_prefix}_merged2-merge.missnp \
      --make-bed --out ${study1_plink_prefix}_common_no_mismatches
   plink --bfile ${study2_plink_prefix}_common_flipped \
      --exclude ${study1_plink_prefix}_${study2_plink_prefix}_merged2-merge.missnp \
      --make-bed --out ${study2_plink_prefix}_common_no_mismatches
   plink --bfile ${study1_plink_prefix}_common_no_mismatches \
      --bmerge ${study2_plink_prefix}_common_no_mismatches.bed ${study2_plink_prefix}_common_no_mismatches.bim ${study2_plink_prefix}_common_no_mismatches.fam \
      --make-bed --out ${study1_plink_prefix}_${study2_plink_prefix}_merged3
else
   plink --bfile ${study1_plink_prefix}_${study2_plink_prefix}_merged2 \
      --make-bed --out ${study1_plink_prefix}_${study2_plink_prefix}_merged3
fi

#Remove SNPs with large missingness and apply MAF filtere
plink --bfile ${study1_plink_prefix}_${study2_plink_prefix}_merged3 \
   --geno $min_geno --maf $min_maf \
   --make-bed --out ${study1_plink_prefix}_${study2_plink_prefix}_merged_clean


