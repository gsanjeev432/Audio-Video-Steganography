%% clear all commands / workspace / history
close all;
clear;
clc;
 
%To get audio alone from the file
file='VIDEO_STEGANOGRAPHY.avi';
file1='orig_video_audio.wav'; %o/p file name
[input_file, Fs] = audioread(file);
audiowrite(file1, input_file, Fs);
  
%% load data
[host, f] = audioread ('orig_video_audio.wav');   % host signal
[signal, fs] = audioread ('a.wav');   % host signal
host = host(:,1);
host =  reshape(host,1,[]);


m = signal(:,1);
fp = 4;

pn_code = randi([0,1],1,length(m)*fp);

for bit = 1:length(pn_code)
   if(pn_code(bit)==0)
        pn_code(bit) = -1;
   end
end

message =  repmat(m,fp,1);
message =  reshape(message,1,[]);

DSSS = message.*pn_code;
stego = interleave(host,DSSS);
host = stego';
host      = uint8(255*(host + 0.5));  % double [-0.5 +0.5] to 'uint8' [0 255]
 
[host2, f] = audioread ('a.wav');   % host signal
host2      = uint8(255*(host2 + 0.5));  % double [-0.5 +0.5] to 'uint8' [0 255]
 
len_host2 = length(host2);
 
host_bin  = dec2bin(host, 8);         % binary host [n 8]
host2_bin = dec2bin(host2, 8);         % binary host [n 8]
 
host_bin_new = host_bin;
 
i=1;
j = 1;
z = 1;
%while i < length(host)
  while j < length(host2)
    while z <= 4
       if (z == 1)
         host_bin_new (i,(7:8)) = host2_bin (j,(1:2));
       elseif (z == 2)
         host_bin_new (i,(7:8)) = host2_bin (j,(3:4));
       elseif (z == 3)
         host_bin_new (i,(7:8)) = host2_bin (j,(5:6));
       elseif (z == 4) 
         host_bin_new (i,(7:8)) = host2_bin (j,(7:8));       
       end
       z = z + 1;
       i = i + 1;
    end
    j = j + 1;
    i = i + 1;
    z = 1;
  end
%end  
 
%% watermarked host
%host_new  = bin2dec(host_bin);       % watermarked host
host_new1  = bin2dec(host_bin_new);       % watermarked host
 
%host2_new  = bin2dec(host2_bin);       % watermarked host
host_new  = (double(host_new1)/255 - 0.5);   % 'uint8' [0 255] to double [-0.5 +0.5]


%% save the watermarked host
audiowrite('stego_audio.wav',host_new, 44100)     % save watermarked host ausio
%audiowrite(host_new, 20, 'stego_audio.wav')     % save watermarked host ausio
%end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%to generate stego video
% file declared at top as original AVI file
file='VIDEO_STEGANOGRAPHY.avi';
hmfr1=vision.VideoFileReader(file,'AudioOutputPort',true,'VideoOutputDataType','uint8');
 
finfo = info(hmfr1);
 
file2='stego_video.avi';
 
hmfw1 = vision.VideoFileWriter(file2,'AudioInputPort',true,'FrameRate',finfo.VideoFrameRate,'FileFormat','AVI');

 
%% find out size of video frames
len_audio = length(host_new);
m = finfo.VideoSize;
len_frames = m(1) + m(2);
 
numAudio = size(host_new,1);
%numRep = floor(numAudio/len_frames);
numRep = len_frames;
 
% total number of frames
%nFrames   = 250;
nFrames   = floor(numAudio/numRep)

%while ~isDone(hmfr1)
for i = 1:nFrames
 [videoFrame,audioFrame2] = step(hmfr1);
 if i == 1
    imagesc(videoFrame)
    [f, p]=uigetfile('*.jpg;*.png','');
    path=[p f];
    hidden01 = imread(path);
    hidden01 = rgb2gray(hidden01);
    hidden01 = imresize(hidden01,[400,400]);
    figure(2)
    image(hidden01) 
    flatImage = flatten(hidden01);
    imshow(flatImage); 
    %---Part 2: Embedding the Images 
    %---This first technique is the Odd/Even Red Embedding
    flatPic = flatten(hidden01); 
    for m = 1:length(flatPic)
        for n = 1:length(flatPic) 
            if(xor(flatPic(m,n) == 1, mod(videoFrame(m,n),2) == 1))
                videoFrame(m,n,1) = videoFrame(m,n,1) - 1;
            elseif(xor(flatPic(m,n) == 0,mod(videoFrame(m,n),2) == 0))
                videoFrame(m,n,1) = videoFrame(m,n,1); 
            end 
        end 
    end 
    figure; imshow(videoFrame); title('Embedded image')
  end
 %step(hmfw1,videoFrame,audioFrame2(:,1));
 step(hmfw1,videoFrame,host_new(numRep*(i-1)+1:numRep*i,:));
 
end
 
release(hmfr1); 
release(hmfw1);

function C = interleave(A,B)
    N = min(numel(A),numel(B));
    C = [reshape([A(1:N);B(1:N)],1,[]),A(N+1:end),B(N+1:end)];
end

 function y = flatten(I) 
threshold = 128; 
flatPic = (I > threshold); 
y = flatPic;
end 

