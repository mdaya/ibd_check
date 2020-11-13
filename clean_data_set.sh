#!/bin/bash

plink_in_file=$1
plink_prefix=$2

#Remove all non-autosomal SNPs
plink2 --bfile $plink_in_file \
   --autosome \
   --make-bed --out ${plink_prefix}_autosome

#Remove all strand ambiguous SNPs
cat ${plink_prefix}_autosome.bim | awk '{print $2"\t"$5 $6}' | grep AT$ | cut -f1 > ${plink_prefix}_strand_amb_variants.txt
cat ${plink_prefix}_autosome.bim | awk '{print $2"\t"$5 $6}' | grep TA$ | cut -f1 >> ${plink_prefix}_strand_amb_variants.txt
cat ${plink_prefix}_autosome.bim | awk '{print $2"\t"$5 $6}' | grep CG$ | cut -f1 >> ${plink_prefix}_strand_amb_variants.txt
cat ${plink_prefix}_autosome.bim | awk '{print $2"\t"$5 $6}' | grep GC$ | cut -f1 >> ${plink_prefix}_strand_amb_variants.txt
plink2 --bfile ${plink_prefix}_autosome \
   --exclude ${plink_prefix}_strand_amb_variants.txt \
   --make-bed --out ${plink_prefix}_autosome_no_strand_amb

#Remove all variants with duplicate IDs
cat ${plink_prefix}_autosome_no_strand_amb.bim | awk '{print $2}' | sort | uniq -d > ${plink_prefix}_dupl_snp_ids.txt
plink2 --bfile ${plink_prefix}_autosome_no_strand_amb \
   --exclude ${plink_prefix}_dupl_snp_ids.txt \
   --make-bed --out ${plink_prefix}_autosome_no_strand_amb_no_dupl_snp_ids

#Update PLINK SNP names as chr:position
cat ${plink_prefix}_autosome_no_strand_amb_no_dupl_snp_ids.bim | awk '{print $2"\t"$1":"$4}' > ${plink_prefix}_new_snp_ids.txt
plink2 --bfile ${plink_prefix}_autosome_no_strand_amb_no_dupl_snp_ids \
   --update-map ${plink_prefix}_new_snp_ids.txt --update-name \
   --make-bed --out ${plink_prefix}_autosome_no_strand_amb_no_dupl_snp_ids_chr_pos_snp_ids

#Remove all variants with duplicate positions
cat ${plink_prefix}_autosome_no_strand_amb_no_dupl_snp_ids_chr_pos_snp_ids.bim | awk '{print $2}' | sort | uniq -d > ${plink_prefix}_dupl_pos_snps.txt
plink2 --bfile ${plink_prefix}_autosome_no_strand_amb_no_dupl_snp_ids_chr_pos_snp_ids \
   --exclude ${plink_prefix}_dupl_pos_snps.txt \
   --make-bed --out ${plink_prefix}_clean


