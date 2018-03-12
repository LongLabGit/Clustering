function Dat2FIL(datFile,nC,fs,l,r)
%  USAGE
%
%    Dat2FIL(datFile,number of Channels,nChannels,up,down)
%

%
% Copyright @ VIGI, who accepts no blame for error
maxPiece=10*60;%analyze X seconds at a time. here 10 minutes. use for RAM control, increase for minor time speedups
fileinfo = dir(datFile);
total_seconds = fileinfo.bytes/(nC * 2)/fs;
fid = fopen(strrep(datFile,'.dat','.fil'),'w');
bpFilt = designfilt('bandpassfir','FilterOrder',1000,'SampleRate',fs,...
    'CutoffFrequency1',l,'CutoffFrequency2',r);%defailt is 250 3000

% bpFilt = designfilt('bandpassfir', 'StopbandFrequency1', 200, 'PassbandFrequency1', 250,...
%     'PassbandFrequency2', 3000, 'StopbandFrequency2', 3500,...
%     'StopbandAttenuation1', 60, 'PassbandRipple', 1,...
%     'StopbandAttenuation2', 60, 'SampleRate', fs, 'DesignMethod', 'kaiserwin');
% hpFilt=designfilt('highpassfir','StopbandFrequency',250, ...
%          'PassbandFrequency',350,'PassbandRipple',0.5, ...
%          'StopbandAttenuation',65,'SampleRate',fs,'DesignMethod','kaiserwin');
    

start = 0;
stop = total_seconds;
indCut=0;
right = start;
while right < stop
    left = start+indCut*maxPiece;
    right = min(stop,left+maxPiece);
    dur=right-left;
    dataChunk = LoadBinary(datFile,'nChannels',nC,'channels',1:nC,'start',left,'duration',dur,'frequency',fs);
    dataChunk=filtfilt(bpFilt,double(dataChunk*10))/10; %filter in both directions
    fwrite(fid, int16(dataChunk'), 'int16');
    indCut=indCut+1;
    fprintf([num2str(indCut) '/' num2str(ceil((stop-start)/maxPiece)) ', '])
end
fclose(fid);
disp('done')