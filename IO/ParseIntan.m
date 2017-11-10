%get info on your data
reboot;
addpath('Fcns\Intan\')
F='S:\Vigi\Datasets\CorticalSpikes\Data\319\Session2\p2_i2\';
read_Intan_RHD2000_file([F,'info.rhd'],1);%This will just spit out details
%% get time
fileinfo = dir([F,'time.dat']);
num_samples = fileinfo.bytes/4; % int32 = 4 bytes
fid = fopen([F,'time.dat'], 'r');
t = fread(fid, num_samples, 'int32');
fclose(fid);
t = t / frequency_parameters.amplifier_sample_rate; % sample rate from header file
%% Data
num_channels = length(amplifier_channels); % amplifier channel info from header file
fileinfo = dir([F,f,'amplifier.dat']);
num_samples = fileinfo.bytes/(num_channels * 2); % int16 = 2 bytes
fid = fopen([F,f,'amplifier.dat'], 'r');
v = fread(fid, [num_channels, num_samples],'int16');
fclose(fid);
Sig = v * 0.195; % convert to microvolts
save('Data\388A\Raw.mat','Sig')
%% Load a Specific Channel
num_channels = length(amplifier_channels); % amplifier channel info from header file
fileinfo = dir([F,f,'amplifier.dat']);
num_samples = fileinfo.bytes/(num_channels * 2); % int16 = 2 bytes
for ch=1:2%num_channels
    % s1=Sig(Channel,:);
    fid = fopen([F,f,'amplifier.dat'], 'r');
    foo=fread(fid, ch-1,'int16');%throw out the channels until we get up to it
    v = fread(fid, [1, num_samples],'int16',(num_channels-1)*2);%skip is in bytes
    fclose(fid);
    s2 = v * 0.195/1e3; % convert to mV
end
%% Auxilary input
num_channels = length(aux_input_channels); % aux input channel info from header file
fileinfo = dir([F,'auxiliary.dat']);
num_samples = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes
fid = fopen([F,'auxiliary.dat'], 'r');
v = fread(fid, [num_channels, num_samples], 'uint16');
fclose(fid);
Aux = v * 0.0000374; % convert to volts
 %% supply voltage
% num_channels = length(supply_voltage_channels); % supply channel info from header file
% fileinfo = dir([F,f,'supply.dat']);
% num_samples = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes
% fid = fopen([F,f,'supply.dat'], 'r');
% v = fread(fid, [num_channels, num_samples], 'uint16');
% fclose(fid);
% v = v * 0.0000748; % convert to volts
 %% anlog in
num_channels = length(board_adc_channels); % ADC input info from header file
fileinfo = dir([F,'analogin.dat']);
num_samples = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes
fid = fopen([F,'analogin.dat'], 'r');
v = fread(fid, [num_channels, num_samples], 'uint16');
fclose(fid);
v = v * 0.000050354; % convert to volts
aud=v(1,:);

% audiowrite([F,'audio.wav'],aud/max(abs(aud)),2e4);
% Finger=v(2,:);

%%
Fstop = 350;
Fpass = 400;
Astop = 65;
Apass = 0.5;
Fs = 2e4;

d = designfilt('highpassfir','StopbandFrequency',Fstop, ...
  'PassbandFrequency',Fpass,'StopbandAttenuation',Astop, ...
  'PassbandRipple',Apass,'SampleRate',Fs,'DesignMethod','equiripple');
audio=filtfilt(d,aud);
audiowrite([F,'audio.wav'],audio/max(abs(audio)),2e4)
audiowrite([F,'audioOrig.wav'],aud/max(abs(aud)),2e4)
% save('Data\388A\IntanAudio.mat','aud')
% fs=20e3;
% w=v;

% [~,F,T,P]=spectrogram(w,512,384,0:10:8e3,fs);%make it
% S=10*log10(P);
% imagesc(T,F,S);set(gca,'ydir','normal')
% cmap=colormap(jet);    cmap(1:8,3)=linspace(0,1,8);    colormap(cmap);
% set(gca,'clim',[min(S(:))+.5*range(S(:)),max(S(:))]);%change the colors
%% get time
fileinfo = dir([F,f,'time.dat']);
num_samples = fileinfo.bytes/4; % int32 = 4 bytes
fid = fopen([F,f,'time.dat'], 'r');
t = fread(fid, num_samples, 'int32');
fclose(fid);
t = t / frequency_parameters.amplifier_sample_rate; % sample rate from header file
%% Data
num_channels = length(amplifier_channels); % amplifier channel info from header file
fileinfo = dir([F,f,'amplifier.dat']);
num_samples = fileinfo.bytes/(num_channels * 2); % int16 = 2 bytes
fid = fopen([F,f,'amplifier.dat'], 'r');
v = fread(fid, [num_channels, num_samples],'int16');
fclose(fid);
Sig = v * 0.195; % convert to microvolts
%% Load a Specific Channel
ch=100;
num_channels = length(amplifier_channels); % amplifier channel info from header file
fileinfo = dir([F,f,'amplifier.dat']);
num_samples = fileinfo.bytes/(num_channels * 2); % int16 = 2 bytes
s1=Sig(ch,:);
fid = fopen([F,f,'amplifier.dat'], 'r');
foo=fread(fid, ch-1,'int16');%throw out the channels until we get up to it
v = fread(fid, [1, num_samples],'int16',(num_channels-1)*2);%skip is in bytes
fclose(fid);
%% digital in
fileinfo = dir([F,f,'digitalin.dat']);
num_samples = fileinfo.bytes/2; % uint16 = 2 bytes
fid = fopen([F,f,'digitalin.dat'], 'r');
digital_word = fread(fid, num_samples, 'uint16');
fclose(fid);
chan=sparse(16,length(digital_word));
ids=unique(digital_word);
for id=1:length(ids)
    locs=logical(de2bi(ids(id),16));
    inds=digital_word==ids(id);
    sum(inds)
    chan(locs,inds)=1;
end
% %% digital out
% fileinfo = dir('digitalout.dat');
% num_samples = fileinfo.bytes/2; % uint16 = 2 bytes
% fid = fopen('digitalout.dat', 'r');
% digital_word = fread(fid, num_samples, 'uint16');
% fclose(fid);