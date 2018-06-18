function [meanWF, timeAxis] = load_average_cluster_waveform(clusters, params, datFilename, downSampleFactor)

load(fullfile(params.SiProbeFolder,'KS_Output.mat'));
load(ops.chanMap,'AnatGroup','connected', 'xcoords', 'ycoords');
SiProbeSamplingInterval = params.SiProbeSamplingInterval;

% exampleClusters = [2 15];
timeAxis = [];
meanWF = [];
% for n = 1:length(clusters)
for n = 35
    fprintf('Loading average waveform of cluster %d\r', clusters(n).clusterID);
    tmpDownSampleFactor = downSampleFactor;
    if length(clusters(n).spikeTimes) < 2*downSampleFactor
        tmpDownSampleFactor = 1;
    end
    sampleTimes = round(clusters(n).spikeTimes(1:tmpDownSampleFactor:end)/SiProbeSamplingInterval);
    sampleWindow = [-2.5/SiProbeSamplingInterval/1000 2.5/SiProbeSamplingInterval/1000];
    deltaWindow = sampleWindow(2) - sampleWindow(1);
    medianEndBin = floor(deltaWindow/3);
    % for backwards compatibility (RE)
%     lookUpChannels = [AnatGroup{:}];
%     lookUpChannels = lookUpChannels(connected);
%     channel = lookUpChannels(clusters(n).maxChannel+1)+1;
    channel = clusters(n).maxChannel+1;
    [tmpWF, ~] = readWaveformsFromDat(datFilename, 64, channel, sampleTimes, sampleWindow, []);
    medianEndBin = min(medianEndBin, length(tmpWF));
    tmpWF = tmpWF - median(tmpWF(1:medianEndBin));
    try
        meanWF = [meanWF; tmpWF'];
    catch
        dummy = 1;
    end
    timeAxis = [timeAxis; (1:length(tmpWF))*1000*SiProbeSamplingInterval];
end

end