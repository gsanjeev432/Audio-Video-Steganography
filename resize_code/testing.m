clc;
% clear all;
close all;

label = ["1","2","3","4","5"];
load net
k=1;

% access file from folder
[f p]=uigetfile('*.jpg;*.png','');
path=[p f];
% im = imread(path);
im=customreader(path);
figure,imshow(im), title('Input Image');

pixelRange = [-15 15];
inputSize = net.Layers(1).InputSize;

augimdsTrain = augmentedImageDatastore(inputSize(1:2),im);
[YPred1,scores1] = classify(net,augimdsTrain)
%output = label(YPred1);

position = [10 10];
box_color = {'red','green','yellow'};
RGB = insertText(im,position,char(YPred1),'FontSize',18);
figure,imshow(RGB), title('output Image');

function data = customreader(filename)
    hidden01 = imread(filename);
    hidden01 = rgb2gray(hidden01);
    threshold = 128; 
    flatPic = (hidden01 > threshold); 
    F = flatPic;
    s = length(F); 
    z = zeros(227,227,3);

    for i = 1:s
        for j = 1:s 
            if(F(i,j) == 1)
                z(i,j,1) = 255;
                z(i,j,2) = 255;
                z(i,j,3) = 255;
            end 

        end 
    end
    data = z;
end



