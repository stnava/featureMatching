#!/bin/bash
dim=$1; a=$2 ; b=$3
nblob=$4
thresh=$5
takegrad=$6
if [[ ! -s $a ]] || [[ ! -s $b ]] ; then 
  echo $0  image1 image2 
  exit
fi
if [[ ${#takegrad} -eq 0 ]] ; then 
  takegrad=1
fi
N3BiasFieldCorrection $dim $a zneg1.nii.gz 8
N3BiasFieldCorrection $dim $b zneg2.nii.gz 8
N3BiasFieldCorrection $dim zneg1.nii.gz zneg1.nii.gz 4
N3BiasFieldCorrection $dim zneg2.nii.gz zneg2.nii.gz 4
ImageMath $dim zmask1.nii.gz Byte $a
ImageMath $dim zmask2.nii.gz Byte $b
ThresholdImage $dim  zmask1.nii.gz  zmask1.nii.gz 10 1.e9
ThresholdImage $dim  zmask2.nii.gz  zmask2.nii.gz 10 1.e9
ImageMath $dim zneg1.nii.gz TruncateImageIntensity zneg1.nii.gz 0.02 0.98 128 
ImageMath $dim zneg2.nii.gz TruncateImageIntensity zneg2.nii.gz 0.02 0.98 128 
MultiplyImages $dim zneg1.nii.gz zmask1.nii.gz zneg1.nii.gz
MultiplyImages $dim zneg2.nii.gz zmask2.nii.gz zneg2.nii.gz
if [[ $takegrad -gt 0  ]] ; then 
  ImageMath $dim zneg1.nii.gz Grad zneg1.nii.gz 1 1
  ImageMath $dim zneg2.nii.gz Grad zneg2.nii.gz 1 1 
fi
ImageMath $dim zneg2.nii.gz HistogramMatch zneg2.nii.gz zneg1.nii.gz 
MultiplyImages $dim zneg1.nii.gz zmask1.nii.gz zneg1.nii.gz
MultiplyImages $dim zneg2.nii.gz zmask2.nii.gz zneg2.nii.gz
ImageMath $dim zneg1.nii.gz  Normalize zneg1.nii.gz 1 
ImageMath $dim zneg2.nii.gz  Normalize zneg2.nii.gz 1
ImageMath $dim zblobn1.nii.gz BlobDetector zneg1.nii.gz $nblob zneg2.nii.gz zblobn2.nii.gz $thresh
temp=`ImageMath $dim zblobn1.nii.gz GD zblobn1.nii.gz 4`
temp=`ImageMath $dim zblobn2.nii.gz GD zblobn2.nii.gz 4`
temp=`MultiplyImages 3 zblobn2.nii.gz 1 zblobn2.nii.gz `
temp=`MultiplyImages 3 zblobn1.nii.gz 1 zblobn1.nii.gz `
temp=`ANTSUseLandmarkImagesToGetAffineTransform zblobn1.nii.gz zblobn2.nii.gz affine zMatchedAffine.txt`
temp=`WarpImageMultiTransform 3 $b zMatched.nii.gz -R $a  zMatchedAffine.txt `
MultiplyImages $dim zMatched.nii.gz 1 zMatched.nii.gz
rm  zneg* z*ffine.txt zmask*  # zblob*
############################################################################################################
