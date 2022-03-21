clc
close all
clearvars
%%
secret_audio=audioread('a.wav');
extracted_secret_audio=audioread('orig_secret_output_a.wav');

peaksnr = psnr(secret_audio,extracted_secret_audio);

ssimval = ssim(secret_audio,extracted_secret_audio);

mse = immse(secret_audio,extracted_secret_audio);

rmse = sqrt(mse);
