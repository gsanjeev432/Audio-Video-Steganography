clc
clearvars
[signal, f] = audioread('orig_video_audio.wav'); 
signal = signal(:,1);
text=audioread('a.wav');
matrix  = dec2bin(uint8(text),8);
bit = reshape(matrix', 1, 8*length(text));
L_min = 8*1024;
graf = 0;

[s.len, s.ch] = size(signal);
L2  = floor(s.len/length(bit));  %Length of segments
L   = max(L_min, L2);            %Keeping length of segments big enough
nframe = floor(s.len/L);
N = nframe - mod(nframe, 8);     %Number of segments (for 8 bits)
if (length(bit) > N)
    warning('Message is too long, is being cropped...');
    bits = bit(1:N);
else
    bits = [bit, num2str(zeros(N-length(bit), 1))'];
end

%Note: Choose r = prng('password', L) to use a pseudo random sequence
r = ones(L,1);
%r = prng('password', L);                %Generating pseudo random sequence
pr = reshape(r * ones(1,N), N*L, 1);  %Extending size of r up to N*L
alpha = 0.005;                          %Embedding strength

%%%%%%%%%%%%%%%%%%%%%%% EMBEDDING MESSAGE... %%%%%%%%%%%%%%%%%%%%%%%%
[mix, datasig] = mixer(L, bits, -1, 1, 256);
out = signal;
stego = signal(1:N*L,1) + alpha * mix.*pr;     %Using first channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out(:,1) = [stego; signal(N*L+1:s.len,1)];     %Adding rest of signal
audiowrite('new_stego_audio.wav',out, 44100)     % save watermarked host ausio


if graf ~= 0
    graph(signal(:,1), out(:,1), bits, datasig, mix, N, L);
end


function out = prng( key, L )
    pass = sum(double(key).*(1:length(key)));
    rand('seed', pass);
    out = 2*(rand(L, 1)>0.5)-1;
end
function [ w_sig, m_sig ] = mixer( L, bits, lower, upper, K )
%MIXER is the mixer signal to smooth data and spread it easier.
%
%   INPUTS VARIABLES
%       L     : Length of segment
%       bits  : Binary sequence (1xm char)
%       K     : Length to be smoothed
%       upper : Upper bound of mixer signal
%       lower : Lower bound of mixer signal
%
%   OUTPUTS VARIABLES
%       m_sig : Mixer signal to spread data
%       w_sig : Smoothed mixer signal
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if (nargin < 4)
    lower = 0;
    upper = 1;
end

if (nargin < 5) || (2*K > L)
	K = floor(L/4) - mod(floor(L/4), 4);
else
    K = K - mod(K, 4);                       %Divisibility by 4
end

N = length(bits);                            %Number of segments
encbit = str2num(reshape(bits, N, 1))';      %char -> double
m_sig  = reshape(ones(L,1)*encbit, N*L, 1);  %Mixer signal
c      = conv(m_sig, hanning(K));            %Hann windowing
wnorm  = c(K/2+1:end-K/2+1) / max(abs(c));   %Normalization
w_sig  = wnorm * (upper-lower)+lower;        %Adjusting bounds
m_sig  = m_sig * (upper-lower)+lower;        %Adjusting bounds

end

function out = hanning(L)
%HANNING() is a manual implentation of hanning window HANN() to be used
%   without Signal Processing Toolbox in MATLAB. Input must be a numeric 
%   greater than zero, so that a hanning window will be generated using  
%   input value as window length.
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if isnumeric(L)
    L = round(L);
    if L == 1
        out = 1;
    elseif L>1 || L==0
        n   = (0:L-1)';
        out = .5*(1-cos((2*pi*n)/(L-1)));
    else
        error('Input must be greater than zero!');
    end
else
    error('Input must be numeric!');
end
    
end