clc;
clear all;
close all;

% [y1,Fs1] = audioread('lion.wav');
% y1 = y1(1:12203,1)
% filename = 'lion2.wav';
% audiowrite(filename,y1,Fs1);


[y1,Fs1] = audioread('lion2.wav');
[y2,Fs2] = audioread('lion\orig_secret_output.wav');


%analysis
%mse
err = immse(y1,y2)

%rmse
rmse = sqrt(err)

%psnr
peaksnr = psnr(y1,y2)

%ssim
ssimval = ssim(y1,y2)

