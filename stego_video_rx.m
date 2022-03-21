%% clear all commands / workspace / history
close all
clear
clc

%To get audio alone from the file
file_rx='stego_video.avi';
file_rx1='stego_audio_rx.wav'; %o/p file name
[input_file, Fs] = audioread(file_rx);
audiowrite(file_rx1, input_file, Fs);

hmfr= vision.VideoFileReader(file_rx,'AudioOutputPort',true,'VideoOutputDataType','uint8');
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

if ~isequal(YPred1,YPred2)
    return
end
disp("run")

%% load data
[host, f2] = audioread('orig_video_audio.wav'); 
host = host(:,1);
host =  reshape(host,1,[]);
[host_r2, f] = audioread ('stego_audio.wav');   % host signal
host_r =  reshape(host_r2,1,[]);

fp = 4;
m = (length(host_r)-length(host))/fp;

pn_code = randi([0,1],1,m*fp);

for bit = 1:length(pn_code)
   if(pn_code(bit)==0)
        pn_code(bit) = -1;
   end
end

orig = deinterleave(host_r,host);
orr = orig.*pn_code;
new = orr(1,1:m);
new = reshape(new,[],1);
host_r2      = uint8(255*(host_r2 + 0.5));  % double [-0.5 +0.5] to 'uint8' [0 255]

hostr_bin  = dec2bin(host_r2, 8);
len_host2 = length(new);

i1=1;
j1 = 1;
z1 = 1;
  while j1 <= len_host2
    while z1 <= 4
	   if (z1 == 1)
	     host_orig_bin (j1,(1:2)) = hostr_bin (i1,(7:8));
	   elseif (z1 == 2)
	     host_orig_bin (j1,(3:4)) = hostr_bin (i1,(7:8));
	   elseif (z1 == 3)
	     host_orig_bin (j1,(5:6)) = hostr_bin (i1,(7:8));
	   elseif (z1== 4) 
	     host_orig_bin (j1,(7:8)) = hostr_bin (i1,(7:8));
       end
	   z1 = z1 + 1;
	   i1 = i1 + 1;
	end
   	j1 = j1 + 1;
	i1 = i1 + 1;
	z1 = 1;
  end
  
host_orig  = bin2dec(host_orig_bin);       % watermarked host
host_orig_new  = (double(host_orig)/255 - 0.5); 


%% save the watermarked host
[~, f] = audioread ('a.wav');   % host signal
audiowrite('orig_secret_output.wav', host_orig_new, f);

function C = deinterleave(A,B)
    C = zeros(1,length(A)-length(B));
    k = 0;
    for i = 1:length(C)*2
        if rem(i,2) == 0
            k = k + 1;
            C(k) = A(i);
        end
    end
end

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
