%
% (C) MERL, 2013
%
% Contributors: Ming-Yu Liu
% Contact     : mliu@merl.com
%
%*************************************************************************
% Please read the following information before running the code.
%
%-------------------------------------------------------------------------
% [ About the code ]
% This batch file computes the performance scores reported in our CVPR2013
% paper.
%
% Ming-Yu Liu, Oncel Tuzel, Yuichi Taguchi
% Joint Geodesic Upsampling of Depth Images
% CVPR2013
% Portland, Oregon, USA
%
%-------------------------------------------------------------------------
% [ About the dataset ]
% We downloaded the mid-size ground truth disparity and color images from 
% the Middlebury Stereo 2005 dataset.
% http://vision.middlebury.edu/stereo/data/scenes2005/
% Note that the image resolution is 695x555.
% 
%-------------------------------------------------------------------------
% [ About the input disparity maps]
% We do subsampling to downsample the ground truth disparity images to
% obtain low resolution disparity images for the input. 
%
%-------------------------------------------------------------------------
% [ About the input disparity maps]
% The results contained in this releas are slightly different to those
% reported in the paper. Some of the scores are slight better while others
% are slightly worse. This is due to a small change in the implementation.
% The performance changes are listed below.
%                       from PAPER to THIS CODE
%  8x DISC error change from 1.19  to 2.00
% 16x DISC error change from 0.33  to 0.34
%  2x SRMS error change from 0.30  to 0.29
%  4x SRMS error change from 0.36  to 0.35
%  8x SRMS error change from 0.67  to 0.62
% 16x SRMS error cahnge from 1.68  to 1.67
% 16x RMS  error change from 0.305 to 0.306
%*************************************************************************
clc;
close all;
clear all;

%
% Configuration for performance evaluation.
%
path = 'Datasets/StereoData/M2005_MID';
outpath = 'Results/StereoData/M2005_MID';
GROUND_TRUTH_CONST = 2;
folders = dir(sprintf('%s',path));
nFolders = length(folders);

%
% Algorithm parameters
%
sigma    = 0.5;
lambda1  = 10;
lambda2  = 1;
interval = 2;

%
% Compute performance
%
ALG_NAME = sprintf('Geodesic_%d_%1.8f_%1.8f_%1.8f',interval,sigma,lambda1,lambda2);
clear rmse;
clear disc;
clear srmse;
gIdx = 0;
uidx = 0;
for usr=[2 4 8 16]
uidx = uidx + 1;
fidx = 0;
    for i=1:nFolders
        if( length( folders(i).name ) > 2 )
            imgFiles = dir(sprintf('%s/%s/view*',path,folders(i).name));
            dispFiles = dir(sprintf('%s/%s/disp*',path,folders(i).name));
            nFiles = length(imgFiles);
            for j=1:nFiles
                fidx = fidx + 1;
                dispImg = imread( sprintf('%s/%s/%s',path,folders(i).name,dispFiles(j).name) );
                estImg  = imread( sprintf('%s/%s/%s_%s_%02d.png',outpath,ALG_NAME,folders(i).name,imgFiles(j).name(1:end-4),usr) );
                [rmse(uidx,fidx) disc(uidx,fidx) srmse(uidx,fidx)] = compute_scores(double(dispImg)/GROUND_TRUTH_CONST,double(estImg)/GROUND_TRUTH_CONST);
            end        
        end
    end
end
gIdx = gIdx + 1;
grmse(gIdx,:)   = mean(rmse,2);
gdisc(gIdx,:)   = mean(disc,2);
gsrmse(gIdx,:)  = mean(srmse,2);

%
% Display the performance parameters
%
count = 1;
for usr=[2 4 8 16]
    fprintf(1,'Upsample ratio = %02d, disc = %1.3f, rms = %1.3f, srms = %1.3f\n',...
        usr, gdisc(count), grmse(count), gsrmse(count) );
    count = count + 1;
end



