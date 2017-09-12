function clusters = loadKiloSortClusters(SiProbePath, SiProbeSamplingInterval)

%Load in from KiloSort
try%regular mode
    load(fullfile(SiProbePath,'batches\KS_Output.mat'));
    clust_id=readNPY(fullfile(SiProbePath,'batches\spike_clusters.npy'));
    clust_group=importdata(fullfile(SiProbePath,'batches\cluster_groups.csv'));
catch%developer mode
    load(fullfile(SiProbePath,'KS_Output.mat'));
    clust_id=readNPY(fullfile(SiProbePath,'spike_clusters.npy'));
    clust_group=importdata(fullfile(SiProbePath,'cluster_group.tsv'));
end
load(ops.chanMap,'connected', 'xcoords', 'ycoords','kcoords');
% cOrder=[AnatGroup{:}]+1;
% clusts=double(unique(clust_id)')';
clusterLabels = cell(length(clust_group) - 1, 2);
for i = 1:length(clust_group) - 1
    line = textscan(clust_group{i+1},'%d %s');
    clusterLabels{i, 1} = line{2};%label assigned to the cluster
    clusterLabels{i, 2} = line{1};%cluster id 
end

goodClusterNames = strcmp([clusterLabels{:,1}],'good');%only take good
goodSpikeIndices = ismember(clust_id, [clusterLabels{goodClusterNames,2}]);
goodClusters = unique(clust_id(goodSpikeIndices));
clusters=struct('spikeTimes',[],'clusterID',[],'maxChannel',[],'coordinates',[],'shank',[]);
for i = 1:length(goodClusters)
    clusterOfInterest = goodClusters(i);
    clusterSpikeIndices = ismember(clust_id, clusterOfInterest);
    clusterSpikeTimes = SiProbeSamplingInterval*rez.st3(clusterSpikeIndices,1);
    %Find (channel) location of max waveform
    tmpSpike = clust_id==clusterOfInterest;
    origC = unique(rez.st3(tmpSpike,2));
    meanTemplate = mean(rez.Wraw(:,:,origC),3);    
    [~,KS_channel] = max(mean(abs(meanTemplate ),2));
    
    clusters(i).spikeTimes = unique(clusterSpikeTimes);
    clusters(i).clusterID = clusterOfInterest;
    clusters(i).maxChannel = KS_channel - 1;
    clusters(i).coordinates = [xcoords(KS_channel) ycoords(KS_channel)];
    clusters(i).shank=kcoords(KS_channel);
end