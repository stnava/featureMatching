featureMatching
===============

get some feature points from similar images &amp; match the images based on those features

depends on ANTs

./featureMatch.sh 2 data/r16slice.nii.gz data/r16rotpart.nii.gz  400 20  1
./featureMatch.sh 2 data/slide1.nii.gz data/slide2.nii.gz  200 50 0
./featureMatch.sh 3 data/time1.nii.gz data/time2.nii.gz  400 50 1

all output starts with letter z and output will be overwritten each time you run featureMatch

