%
% (C) MERL, 2013
%
% Contributors: Ming-Yu Liu
% Contact     : mliu@merl.com
%
function [rmse disc srmse] = compute_scores(gtImg,estImg)
%
% This function reads a ground truth disparity map and an estimated
% disparity map and computes the performance scores reported in our CVPR'13
% paper.
%
% Ming-Yu Liu, Oncel Tuzel, Yuichi Taguchi
% Joint Geodesic Upsampling of Depth Images
% IEEE Conference on Computer Vision and Pattern Recognition 2013, CVPR2013
% Portland, Oregon, USA
%
%
% [Input]
%   gtImg   : ground truth disparity map
%   estImg  : estimated disparity map
%
% [Output]
%   rms     : root-mean-square error
%   srms    : root-mean-square error in the depth smooth region
%   disc    : disparity error rate in the depth discontinuous region
%
thresh = 1;
rmse  = compute_rms(gtImg,estImg);
srmse = compute_smooth_rmse(gtImg,estImg);
disc  = compute_disc(gtImg,estImg,thresh);

function rmse = compute_rms(gtImg,estImg)
%
% compute root mean square error
% We exclude disparity value in the occluded area from performance score
% computation.
%
idx = find(gtImg>0);
rmse = sqrt( mean( (estImg(idx)-gtImg(idx)).^2 ) ) ;

function srmse = compute_smooth_rmse(gtImg,estImg)
%
% compute root mean square error in the depth smooth area
% We exclude disparity value in the occluded area from performance score
% computation. We exclude disparity pixels near boundaries from performance
% score computation.
%
eMap = edge(gtImg,'canny');
deMap = bwmorph(eMap,'dilate',2);
idx  = find((deMap==0).*(gtImg>0)>0);
srmse = sqrt( mean( (estImg(idx)-gtImg(idx)).^2 ) ) ;

function [disc] = compute_disc(gtImg,estImg,thresh)
%
% compute error rate in the depth discountinuous region
% We extract canny edges from the ground truth disparity map and dilate
% them to cover a small amount of neighboring pixels. The error rate is
% computed using only within the region. Note that bad pixels due to
% occlusion are excluded in the performance computation.
%
eMap = edge(gtImg,'canny');
deMap = bwmorph(eMap,'dilate',2);
idx  = find((deMap>0).*(gtImg>0)>0);
disc = sum( abs(estImg(idx)-gtImg(idx)) > thresh );
disc = disc/length(idx);

