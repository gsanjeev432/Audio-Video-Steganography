[signal, f] = audioread('new_stego_audio.wav');
[text,cf]=audioread('a.wav');
L_msg = 8*length(text);
L_min = 8*1024; 
s.len  = length(signal(:,1));
L2 = floor(s.len/L_msg);
L  = max(L_min, L2);           %Length of segments
nframe = floor(s.len/L);
N = nframe - mod(nframe, 8);   %Number of segments

xsig = reshape(signal(1:N*L,1), L, N);  %Divide signal into N segments

%Note: Choose r = prng('password', L) to use a pseudo random sequence
r = ones(L,1);
%r = prng('password', L);       %Generating same pseudo random sequence

data = num2str(zeros(N,1))';
c = zeros(1,N);
for k=1:N  
    c(k)=sum(xsig(:,k).*r)/L;   %Correlation
    if c(k)<=0
        data(k) = '0';
    else
        data(k) = '1';
    end      
end

bin = reshape(data(1:N), 8, N/8)';
str = char(bin2dec(bin))';

function out = prng( key, L )
    pass = sum(double(key).*(1:length(key)));
    rand('seed', pass);
    out = 2*(rand(L, 1)>0.5)-1;
end