function audio=generateAudio(F,chan,write,test)
[fs,~,nA,~]=read_Intan_RHD2000_V([F,'info.rhd'],0);
fileinfo = dir([F,'analogin.dat']);
num_samples = fileinfo.bytes/2; % uint16 = 2 bytes
fid = fopen([F,'analogin.dat'], 'r');
v = fread(fid, [nA, num_samples], 'uint16');
fclose(fid);
v = v(chan,:) * 0.000050354; % Magic number - convert to volts
%high pass filter the signal
b = fir1(48,750/(fs/2),'high');
audio=filtfilt(b,1,v);
audio=audio/max(audio);
if write
    audiowrite([F,'audio.wav'],audio,fs)
end
if test
  for s=1%:size(tPlayback,1)
        figure(s);clf;hold on;
        for t=1:size(tPlayback,1)
            inds=round(tPlayback(t,s)+(0:(lenStim*2e4)));%make lenStim actuall match the stimuli
            plot((1:length(inds))/2e4 ,audio(inds)+t)
        end
  end
end