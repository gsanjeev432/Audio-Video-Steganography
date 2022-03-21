clc
clearvars

file1='123.avi'; %o/p file name
hmfr= vision.VideoFileReader(file1,'AudioOutputPort',true,'VideoOutputDataType','uint8');
count = 0;
for i = 1:1
    [videoFrame,audioFrame] = step(hmfr);
    recoveredImage = zeros(400); 
    size = length(recoveredImage); 
    for p = 1:size
        for q = 1:size 
            if(mod(videoFrame(p,q,1),2) == 1)
                recoveredImage(p,q) = 1;
            else 
                recoveredImage(p,q) = 0; 
            end 
        end 
    end 
    recoveredImage = expand(recoveredImage);
    figure; imshow(recoveredImage); title('Recovered Image')
end

release(hmfr);
load net

[f,p]=uigetfile('*.jpg;*.png','');
path=[p f];
im = customreader(path);
figure,imshow(im), title('Input Image');

inputSize = net.Layers(1).InputSize;

augimdsTrain = augmentedImageDatastore(inputSize(1:2),im);
[YPred1,scores1] = classify(net,augimdsTrain);

augimdsTest = augmentedImageDatastore(inputSize(1:2),recoveredImage);
[YPred2,scores2] = classify(net,augimdsTest);

function z = expand(F)
%--converts the b/w image into a RBG image 
%--A 255 value is a white value
%--zero values are black values 
%--zeros creates an nxnx3 matrix 
%--z(:,:1), z(:,:,2), z(:,:,3) creates the RGB intensities 

s = length(F); 
z = zeros(s,3);

for i = 1:s
    for j = 1:s 
        if(F(i,j) == 1)
            z(i,j,1) = 255;
            z(i,j,2) = 255;
            z(i,j,3) = 255;
        end 

    end 
end 
end 

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
