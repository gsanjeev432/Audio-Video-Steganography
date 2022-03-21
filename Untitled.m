clc;
clear all;
close all;

filename = 'orig_secret_output.wav';
[yin,Fs] = audioread(filename);
%sound(yin,Fs);
info = audioinfo(filename);
t = 0:seconds(1/Fs):seconds(info.Duration);
t = t(1:size(yin));
figure(1), plot(t,yin), xlabel('Time'), ylabel('Amplitude'), title('Amplitude Vs Time')
