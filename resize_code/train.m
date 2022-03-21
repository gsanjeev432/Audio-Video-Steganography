clc
close all
clearvars

%% load image data
imds = imageDatastore('resized\Train', ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');
imds.ReadFcn = @customreader;

%% split train test data
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.7,'randomized');

%%convert label string into numerals
numTrainImages = numel(imdsTrain.Labels);
idx = randperm(numTrainImages,16);
figure
for i = 1:16
    subplot(4,4,i)
    I = readimage(imdsTrain,idx(i));
    imshow(I)
end

labelCount = countEachLabel(imds);

img = readimage(imds,1);

size(img)

%%Load VGG transfer learning network
net = alexnet;
%%
inputSize = net.Layers(1).InputSize

%%remove last 3 columns of vgg net(it contains label of vgg16)
layersTransfer = net.Layers(1:end-3);
numClasses = numel(categories(imdsTrain.Labels))
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

%% image data augumentation (Translation)

pixelRange = [-15 15];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);

%% Validation data
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter);
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

options = trainingOptions('sgdm', ...
    'MiniBatchSize',64, ...
    'InitialLearnRate',0.0001, ...
    'MaxEpochs',10, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',10, ...
    'Verbose',false, ...
    'Plots','training-progress');

net = trainNetwork(imdsTrain,layers,options);
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;
accuracy = sum(YPred == YValidation)/numel(YValidation)
save net

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