function spliceBinaries(F,ampFile,samplingRate,nChan,times,channels)
%Input
% F: folder with the data
% ampFile:  This will be written as cut_FILE
% samplingRate: Fs
% nAmp:   # of channels in your probe/amplifier
% nAnalog: 
%you can leave these empty if  there is an info.rhd file in your folder
% times: matrix of N x 2, where N is the number of segments you want to
% splice together, and each columb is the start and stop IN SECONDS. leave
% empoty to use all
% channels: channels to cut. leave empty to use all. 
%Output: none, but there will be new files in the folder
maxPiece=10*60;%analyze X seconds at a time. here 10 minutes. use for RAM control, increase for minor time speedups
if isempty(times)&&isempty(channels)
    error('uggggghhhh')
end
if isempty(channels)
    channels=1:nChan;
end
if isempty(times)
    fileinfo = dir([F,ampFile]);
    stop = fileinfo.bytes/(nC * 2)/fs;
    times=[0,stop];
end
%%
ampFileCut = fopen([F,'cut_' ampFile], 'w');
for t = 1:size(times,1)
    start = times(t,1);
    stop = times(t,2);
    indCut=0;
    right = start;
    fprintf(['Starting Amp Time Segment #' num2str(t) '/' num2str(size(t,1)) ': '])
    while right < stop
        left = start+indCut*maxPiece;
        right = min(stop,left+maxPiece);
        dataChunk = LoadBinary([F,'amplifier.dat'],'nChannels',nChan,'channels',channels,'start',left,'duration',right-left,'frequency',samplingRate);%SWAP TO ALL SHANKS?
        fwrite(ampFileCut, dataChunk', 'int16');
        indCut=indCut+1;
        fprintf([num2str(indCut) '/' num2str(ceil((stop-start)/maxPiece)) ', '])
    end
    disp('done')
end
fclose(ampFileCut);
disp('done')