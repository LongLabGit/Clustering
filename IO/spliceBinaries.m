function spliceBinaries(F,ampFile,analogFile,samplingRate,nAmp,nAnalog,times)
%Input
% F: folder with the data
% ampFile:  This will be written as cut_FILE
% analogFile: same for analog file. Either one of these can be empty
%  We can adapt this to do the binary inputs too. not in yet though
% samplingRate: Fs
% nAmp:   # of channels in your probe/amplifier
% nAnalog: 
%you can leave these empty if  there is an info.rhd file in your folder
% times: matrix of N x 2, where N is the number of segments you want to
% splice together, and each columb is the start and stop IN SECONDS

%Output: none, but there will be new files in the folder
maxPiece=10*60;%analyze X seconds at a time. here 10 minutes. use for RAM control, increase for minor time speedups

%%
if isempty(samplingRate)
    try
        [samplingRate,nAmp,nAnalog,~]=read_Intan_RHD2000_V([F,'info.rhd'],0);
    catch
        error('No Info.rhd file found AND you didnt give me the info. I need one of them')
    end
end
if ~isempty(ampFile)
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
            dataChunk = LoadBinary([F,'amplifier.dat'],'nChannels',nAmp,'channels',1:nAmp,'start',left,'duration',right-left,'frequency',samplingRate);%SWAP TO ALL SHANKS?
            fwrite(ampFileCut, dataChunk', 'int16');
            indCut=indCut+1;
            fprintf([num2str(indCut) '/' num2str(ceil((stop-start)/maxPiece)) ', '])
        end
        disp('done')
    end
    fclose(ampFileCut);
    disp('done with ampfile')
else
    disp('no amp file, skipping')
end

if ~isempty(analogFile)
    analogFileCut = fopen([F,'cut_' analogFile], 'w');
    for t = 1:size(times,1)
        start = times(t,1);
        stop = times(t,2);
        indCut=0;
        right = start;
        fprintf(['Starting Analogin Chunk #' num2str(t) '/' num2str(size(t,1)) ': '])
        while right < stop
            left = start+indCut*maxPiece;
            right = min(stop,left+maxPiece);
            dataChunk = LoadBinary([F,'analogin.dat'],'nChannels',nAnalog,'channels',1:nAnalog,'start',left,'duration',right-left,'frequency',samplingRate);
            fwrite(analogFileCut, dataChunk', 'int16');
            indCut=indCut+1;
            fprintf([num2str(indCut) '/' num2str(ceil((stop-start)/maxPiece)) ', '])
        end
        disp('done')
    end
    fclose(analogFileCut);
    disp('done with analog file')
else
    disp('no analog file given, skipping')
end