%Peter Alameda
%Section A01, Winter Quarter 2015
%2nd Quarter Project, Project #3 Stenography 
clc
clearvars

%To get audio alone from the file
file='VIDEO_STEGANOGRAPHY.avi';
file1='123.avi'; %o/p file name
hmfr= vision.VideoFileReader(file,'AudioOutputPort',true,'VideoOutputDataType','uint8');
finfo = info(hmfr);
hmfw = vision.VideoFileWriter(file1,'FrameRate',finfo.VideoFrameRate,'FileFormat','AVI','AudioInputPort',true);
count = 0;
while ~isDone(hmfr)
  count = count+1;
  [videoFrame,audioFrame] = step(hmfr);
  if count == 1
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
  step(hmfw,videoFrame,audioFrame);
  disp(count)
end
release(hmfw);
release(hmfr);
  
 function y = flatten(I) 
threshold = 128; 
flatPic = (I > threshold); 
y = flatPic;
end 

