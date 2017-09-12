function [meanWF, timeAxis] = load_average_cluster_waveform(clusters, params, datFilename, downSampleFactor)

load(fullfile(params.SiProbeFolder,'KS_Output.mat'));
load(ops.chanMap,'AnatGroup','connected', 'xcoords', 'ycoords');
SiProbeSamplingInterval = params.SiProbeSamplingInterval;

% exampleClusters = [2 15];
timeAxis = [];
meanWF = [];
for n = 1:length(clusters)
% for n = exampleClusters
    fprintf('Loading average waveform of cluster %d\r', clusters(n).clusterID);
    sampleTimes = round(clusters(n).spikeTimes(1:downSampleFactor:end)/SiProbeSamplingInterval);
    sampleWindow = [-2.5/SiProbeSamplingInterval/1000 2.5/SiProbeSamplingInterval/1000];
    deltaWindow = sampleWindow(2) - sampleWindow(1);
    medianEndBin = floor(deltaWindow/3);
    lookUpChannels = [AnatGroup{:}];
    lookUpChannels = lookUpChannels(connected);
    channel = lookUpChannels(clusters(n).maxChannel+1)+1;
    [tmpWF, ~] = readWaveformsFromDat(datFilename, 64, channel, sampleTimes, sampleWindow, []);
    tmpWF = tmpWF - median(tmpWF(1:medianEndBin));
    meanWF = [meanWF; tmpWF'];
    timeAxis = [timeAxis; (1:length(tmpWF))*1000*SiProbeSamplingInterval];
end

end