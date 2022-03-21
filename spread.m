clc
clearvars
[signal, f] = audioread('a.wav');
[host, f2] = audioread('orig_video_audio.wav'); 
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
orig = deinterleave(stego,host);
orr = orig.*pn_code;
new = orr(1,1:length(m));
new = reshape(new,[],1);
audiowrite('new_stego_audio.wav',stego, 44100)     % save watermarked host audio
% check=isequal(m,new)


function C = interleave(A,B)
    N = min(numel(A),numel(B));
    C = [reshape([A(1:N);B(1:N)],1,[]),A(N+1:end),B(N+1:end)];
end

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