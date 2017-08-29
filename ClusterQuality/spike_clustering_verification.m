

F='F:\Probe_analysis_ML\R5364\450_rec3\';
%  F='F:\Probe_analysis_ML\R5302\350_rec2\';
%  F='F:\Probe_analysis_ML\R5328\550_rec3_170321_190359\';
% F='F:\Probe_analysis_ML\R5370\350_rec6\';
% F='F:\Probe_analysis_ML\R5228\400_160629_165311\';
relevant_shanks=2:7; % shanks within HVC

the_scores=[];
for shank=relevant_shanks(1):relevant_shanks(length(relevant_shanks))
baseFilename=[F,'Klusta\',num2str(shank) '\amplifier'];
shankIndex=num2str(shank-1);

good_clusters = double(goodClustersShank(baseFilename, shank));

[isiV, clusterIDs, total_rate] = isiViolations(baseFilename, shankIndex, 0.002, 0.00005);
isiv_goodcluster2ms=permute(isiV(find(ismember(clusterIDs,good_clusters))),[2,1]); % isiv 2 ms ref period

[isiV, clusterIDs, total_rate] = isiViolations(baseFilename, shankIndex, 0.001, 0.00005);
isiv_goodcluster1ms=permute(isiV(find(ismember(clusterIDs,good_clusters))),[2,1]); % isiv 1 ms ref period


total_rate_goodclusters=permute(total_rate(find(ismember(clusterIDs,good_clusters))),[2,1]); % firing rate

[isiV, clusterIDs] = isiViolations(baseFilename, shankIndex, 0.0005, 0.00005);
isiv_goodcluster0p5ms=permute(isiV(find(ismember(clusterIDs,good_clusters))),[2,1]); % isiv 0.5 ms ref period

isiv_ratio=isiv_goodcluster0p5ms./isiv_goodcluster2ms;

[clusterIDs, unitQuality, contaminationRate] = maskedClusterQuality(baseFilename, shankIndex);
unitQuality_goodclusters=unitQuality(find(ismember(clusterIDs,good_clusters))); % isolation distance
contaminationRate_goodclusters=contaminationRate(find(ismember(clusterIDs,good_clusters)));

the_scores_shank=[ones(length(good_clusters),1)*shank, good_clusters, total_rate_goodclusters, isiv_goodcluster2ms, isiv_goodcluster1ms, isiv_goodcluster0p5ms, isiv_ratio, unitQuality_goodclusters];
the_scores=[the_scores;the_scores_shank];
end
%% L-ratio for all cells 

Lratio_scores=[];
for shank=relevant_shanks(1):relevant_shanks(length(relevant_shanks))
baseFilename=[F,'Klusta\',num2str(shank) '\amplifier'];
shankIndex=num2str(shank-1);
clusterNames =  hdf5read([baseFilename '.kwik'], ['/channel_groups/' num2str(shankIndex) '/spikes/clusters/main']);
featuresAndMasks = hdf5read([baseFilename '.kwx'],  ['/channel_groups/' num2str(shankIndex) '/features_masks']); %  Size is [2, nChan*3, nSpikes]

clusterNames = double(clusterNames);
features = squeeze(featuresAndMasks(1,:,:))';
masks = squeeze(featuresAndMasks(2,:,:))';
clear featuresAndMasks

% clusterIDs = unique(clusterNames);
good_clusters = double(goodClustersShank(baseFilename, shank));
clusterIDs = good_clusters;

  fetN = 12;
  
N = numel(clusterNames);
% assert(size(fet, 2) == size(fmask, 2) && fetN <= size(fet, 2) && ...
%   size(fet, 1) == N && size(fmask, 1) == N, 'bad input(s)')

%clusterIDs = unique(clu);
Lratio_shank=zeros(numel(good_clusters),4);
for c = 1:numel(clusterIDs)
  n = sum(clusterNames == clusterIDs(c)); % #spikes in this cluster
  if n < fetN || n >= N/2
    % cannot compute mahalanobis distance if less data points than
    % dimensions or if > 50% of all spikes are in this cluster
    L(c) =  NaN;
    Lratio(c) = NaN;
    continue
  end
  
  [~, bestFeatures] = sort(mean(masks(clusterNames == clusterIDs(c), :)), 'descend'); % sorting the features by the masks (the higher the mask values, the better a feature is for a given cluster)
  bestFeatures = bestFeatures(1:fetN); % the best fetN features for this cluster
    
  % We don't want to take into consideration spikes that have absolutely
  % nothing to do with these dimensions:
  NoiseSpikes = (clusterNames ~= clusterIDs(c)) & sum(masks(:, bestFeatures), 2) > 0; 
  Fet= features(:,bestFeatures);
  ClusterSpikes=find(clusterNames==clusterIDs(c));
% Fet are feature matrix for ALL spikes in a recording
% ClusterSpikes and the indices in fet of the spikes of the cluster of interest
 [L, Lratio, df] = L_Ratio(Fet, ClusterSpikes);
 [L_n, Lratio_n, df] = L_Ratio_noise(Fet, ClusterSpikes, NoiseSpikes);
 Lratio_shank(c,:)=[Lratio,Lratio_n,shank,clusterIDs(c)];
end
Lratio_scores=[Lratio_scores;Lratio_shank];
end
lratio_table=table(Lratio_scores(:,1),Lratio_scores(:,2),Lratio_scores(:,3),Lratio_scores(:,4));

%% mahal distance overl time: cluster stability:

Stability_scores=[];
for shank=relevant_shanks(1):relevant_shanks(length(relevant_shanks))
baseFilename=[F,'Klusta\',num2str(shank) '\amplifier'];
shankIndex=num2str(shank-1);
clusterNames =  hdf5read([baseFilename '.kwik'], ['/channel_groups/' num2str(shankIndex) '/spikes/clusters/main']);
featuresAndMasks = hdf5read([baseFilename '.kwx'],  ['/channel_groups/' num2str(shankIndex) '/features_masks']); %  Size is [2, nChan*3, nSpikes]

clusterNames = double(clusterNames);
features = squeeze(featuresAndMasks(1,:,:))';
masks = squeeze(featuresAndMasks(2,:,:))';
clear featuresAndMasks

% clusterIDs = unique(clusterNames);
good_clusters = double(goodClustersShank(baseFilename, shank));
clusterIDs = good_clusters;

  fetN = 12;
  
N = numel(clusterNames);
% assert(size(fet, 2) == size(fmask, 2) && fetN <= size(fet, 2) && ...
%   size(fet, 1) == N && size(fmask, 1) == N, 'bad input(s)')

%clusterIDs = unique(clu);
stability_shank=zeros(numel(good_clusters),4);
for c = 1:numel(clusterIDs)
  n = sum(clusterNames == clusterIDs(c)); % #spikes in this cluster
  if n < fetN || n >= N/2
    % cannot compute mahalanobis distance if less data points than
    % dimensions or if > 50% of all spikes are in this cluster
   stability_shank(c,:)=[NaN,NaN,NaN,NaN];
    continue
  end
  
  [~, bestFeatures] = sort(mean(masks(clusterNames == clusterIDs(c), :)), 'descend'); % sorting the features by the masks (the higher the mask values, the better a feature is for a given cluster)
  bestFeatures = bestFeatures(1:fetN); % the best fetN features for this cluster
    
  % We don't want to take into consideration spikes that have absolutely
  % nothing to do with these dimensions:
  % NoiseSpikes = (clusterNames ~= clusterIDs(c)) & sum(masks(:, bestFeatures), 2) > 0; 
  Fet= features(:,bestFeatures);
  ClusterSpikes=find(clusterNames==clusterIDs(c));
  
% Fet are feature matrix for ALL spikes in a recording
% ClusterSpikes and the indices in fet of the spikes of the cluster of interest

FetCluster=Fet(ClusterSpikes,:); % features of spike belonging to current cluster

md_cluster=mahal(FetCluster,FetCluster);
% figure; set(gcf,'Color','white');
% plot(ClusterSpikes,md_cluster,'o'); box off;
% xlabel('t');
% ylabel('Mahalanobis dist');
[R,P]=corrcoef(ClusterSpikes,md_cluster);
stability_shank(c,:)=[R(2,1),P(2,1),shank,clusterIDs(c)];

end
Stability_scores=[Stability_scores;stability_shank];
end
stability_table=table(Stability_scores(:,1),Stability_scores(:,2),Stability_scores(:,3),Stability_scores(:,4));
%%

all_the_scores_table=array2table([the_scores, Lratio_scores(:,2),Stability_scores(:,1)]);
writetable(all_the_scores_table,'F:\Probe_analysis_ML\Analysis\clustering_checking\ClusterScores_test.xlsx','Sheet',1,'Range','A1')

%%
% precision versus scores:
figure; set(gcf,'Color','white');
subplot(2,1,1); plot(the_scores(:,3),precision_alltutor(:,1),'o'); box off; title('isi violations'); ylabel('precision')
subplot(2,1,2); plot(the_scores(:,4),precision_alltutor(:,1),'o'); box off; title('isolation distance'); ylabel('precision')

[R,P]=corrcoef(the_scores(:,3),precision_alltutor(:,1))% R=-0.12; P=0.28;
[R,P]=corrcoef(the_scores(:,4),precision_alltutor(:,1))% R=-0.15; P=0.19;

































