dim=2
for x in 026 048 ; do
  ImageMath $dim grad${x}.nii.gz Grad frames-${x}.nii.gz 10
#  ImageMath $dim grad${x}.nii.gz PadImage frames-${x}.nii.gz 15
#  ImageMath $dim grad${x}.nii.gz Grad grad${x}.nii.gz 10
#  ImageMath $dim grad${x}.nii.gz PadImage grad${x}.nii.gz -70
#  ImageMath $dim grad${x}.nii.gz PadImage grad${x}.nii.gz 70
done
ImageMath $dim blob026.nii.gz BlobDetector grad026.nii.gz 400 grad048.nii.gz blob048.nii.gz 20
ImageMath $dim blob026.nii.gz GD blob026.nii.gz 5
ImageMath $dim blob048.nii.gz GD blob048.nii.gz 5
echo " begin match "
ANTSUseLandmarkImagesToGetAffineTransform blob026.nii.gz blob048.nii.gz affine blobMatch.mat
antsApplyTransforms -d $dim -t blobMatch.mat -i frames-048.nii.gz \
 -r frames-026.nii.gz -o XXX.nii.gz
imgs="grad026.nii.gz,grad048.nii.gz"
imgs="frames-026.nii.gz,frames-048.nii.gz"
antsRegistration -r blobMatch.mat  --dimensionality 2 -f --float 0 --output [output,outputWarped.nii.gz,outputInverseWarped.nii.gz] --interpolation Linear --use-histogram-matching 1 --winsorize-image-intensities [0.005,0.995]  --transform affine[0.1] --convergence [100x70x50x10,1e-6,10] --shrink-factors 4x4x2x1 --smoothing-sigmas 3x2x1x0vox --metric mattes[$imgs,1,32,Regular,0.1] --transform SyN[0.1,6,0.0] --convergence [100x70x50x10,1e-6,10] --shrink-factors 4x4x2x1 --smoothing-sigmas 3x2x1x0vox --metric cc[$imgs,1,4]  -x [mask.nii.gz,mask.nii.gz]
x=048
tx=" -t output1Warp.nii.gz -t output0GenericAffine.mat "
antsApplyTransforms -d 2 $tx  \
   -i frames-${x}.nii.gz -r frames-026.nii.gz  -o XXX2.nii.gz
