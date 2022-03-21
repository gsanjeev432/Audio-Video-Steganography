%% clear all commands / workspace / history
close all
clear
clc
 
 
%To get audio alone from the file
file = 'VIDEO_STEGANOGRAPHY.avi';
file1='orig_video_audio.wav'; %o/p file name
hmfr = audioRead(file,'AudioOutputPort',true,'VideoOutputPort',false);
hmfw = audioWrite(file1,'AudioInputPort',true,'VideoInputPort',false,'FileFormat','WAV');
