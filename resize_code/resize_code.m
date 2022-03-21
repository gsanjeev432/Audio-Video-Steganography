% clc;
% clear all;
% close all;

tic
% import images from specified folder for training
MRI_image = 'E:\USHAI projects\2019-20\BE\10. yogesh bhavathankar\face recognition\dataset\test\2\';
file_ext = '.png';
folder_content = dir ([MRI_image,'*',file_ext]);
% structure with every image details like name,extension,size etc.
mri = size (folder_content,1);

for k=1:mri
    string = [MRI_image,folder_content(k,1).name]; % fetched every image
    im1 = imread(string);
    im1 = imresize(im1,[227,227]);
   imwrite(im1,sprintf('%05d.jpg',k))
end
