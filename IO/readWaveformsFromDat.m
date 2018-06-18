function [meanWF, allWF] = readWaveformsFromDat(datFilename, chansInDat, takeChans,sampleTimes, window, nToRead)
% INPUT
%       datFilename: location of dat file (e.g. C:\Margot\amplifer.dat)
%       chansInDat: # of chanbnels (e.g. 64)
%       takeChans,channels to look at (e.g. [3,4])
%       sampleTimes, times (in samples, not seconds) of spikes
%       window, : width of spike that you want in saples (e.g. [-16,16] would be 33 samples)
%       nToRead: # of spikes. so your cluster in sampletimes might have
%       10,00 spikes, but you only want 100, it selects them randomly 
% OUTPUT

FileInf = dir(datFilename);
nSampsInDat = (FileInf.bytes/chansInDat/2);
rawData = memmapfile(datFilename, 'Format', {'int16', [chansInDat, nSampsInDat], 'x'});

if isempty(nToRead)
    theseTimes = sampleTimes;
    nToRead = length(sampleTimes);
else
    if nToRead>length(sampleTimes)
        nToRead = length(sampleTimes);
    end
    q = randperm(length(sampleTimes));
    theseTimes = sampleTimes(sort(q(1:nToRead)));
end

theseTimes = theseTimes(theseTimes>-window(1) & theseTimes<nSampsInDat-window(2)-1);
nToRead = numel(theseTimes);

if nToRead == diff(window)+1
    nToRead = nToRead - 1;
end
allWF = zeros(length(takeChans), diff(window)+1, nToRead);

for i=1:nToRead
    allWF(:,:,i) = double(rawData.Data.x(takeChans,theseTimes(i)+window(1):theseTimes(i)+window(2)))*.195;
end
allWF=squeeze(allWF);
allWFShape = size(allWF);
if allWFShape(1) == nToRead
    direction = 1;
elseif allWFShape(2) == nToRead
    direction = 2;
end
% meanWF = median(allWF,length(size(allWF)));
meanWF = median(allWF,direction);
if direction == 1
    meanWF = meanWF';
end

