reboot;
addpath(genpath('Extra'))
%Here define the file that you want
F='S:\Vigi\DBS\Data\StatisticalLearning\380\dat\batches\';
%% read in from phy
%Load in from KiloSort
load(fullfile(F,'KS_Output.mat'));
try 
    load(ops.chanMap,'AnatGroup');
    cOrder=[AnatGroup{:}]+1;
catch
    cOrder=1:3;
end
%Load in from TemplateGUI
clust_id=readNPY(fullfile(F,'spike_clusters.npy'));
clust_group=importdata(fullfile(F,'cluster_groups.csv'));
clusts=double(unique(clust_id)')';
%% Parse Clusters
%initialize outputs
load(ops.chanMap,'kcoords','connected')
kcoords=kcoords(connected);
aU = sum(rez.U.^2,3).^.5;%geometric mean, channels x templates
aUgroups = zeros(max(kcoords), size(rez.U,2));%shanks x templates
for j = 2:max(kcoords)
    aUgroups(j, :) = mean(aU(kcoords==j,:), 1);%mean of each template on all shanks
end
[spk_t,rezInds,clust_type,cOrig]=deal(cell(length(clusts),1));
[shank,channel]=deal(nan(length(clusts),1));
for i=1:length(clusts)
    foo=textscan(clust_group{i+1},'%*d %s');
    clust_type(i)=foo{1};
    ii=find(clust_id==clusts(i));
    [spk_t{i},ia]=unique(rez.st3(ii,1));
    rezInds{i}=ii(ia);
%     doubled(i)=length(spk_t{i})-length(unique(spk_t{i}));
    origC=unique(rez.st3(rezInds{i},2));
    wa = mean(rez.Wraw(:,:,origC),3);    %Find Location of Max
    [~,channel(i)]= max(mean(abs(wa),2));%
    [~,shank(i)]=max(sum(aUgroups(:,origC),2));
    cOrig{i}=origC-1;
end
nSpikes=cellfun(@length,spk_t);
%%
rm=strcmp(clust_type,'noise')|nSpikes<100|strcmp(clust_type,'mua');
clust_type(rm)=[];
spk_t(rm)=[];
shank(rm)=[];
channel(rm)=[];
rezInds(rm)=[];
clusts(rm)=[];
cOrig(rm)=[];
length(clust_type)
[sum(strcmp(clust_type,'good')), sum(strcmp(clust_type,'mua')), sum(strcmp(clust_type,'noise')),sum(strcmp(clust_type,'unsorted'))]
%% Check Histogram Across Time
set(0,'DefaultFigureWindowStyle','docked')
bw=1;
% cCheck=[220,259]-1;
cCheck=clusts(strcmp(clust_type,'good'));
for c=1:length(cCheck)
    figure(c);
    t=spk_t{cCheck(c)==clusts}/2e4;
    bins=0:bw:(max(t));
    [n,edges]=histcounts(t,bins);
    b=bar(edges(1:end-1)/60,n,'histc');
    xlabel('time (m)')
    ylabel('Hz')
    axis tight;
    title(['cluster ', num2str(cCheck(c))])
end
%% Plot on Map
nSpikes=cellfun(@length,spk_t);
% for i=1:8
%     fprintf('Shank #%i:',i)
%     fprintf(' %i',clusts(shank==i))%subtract off 1 for phy
%     totS(i)=sum(nSpikes(shank==i));
%     totC(i)=sum(shank==i);
%     fprintf('| %i Spikes',totS(i))%subtract off 1 for phy
%     fprintf(', %i clusts',totC(i))%subtract off 1 for phy
%     fprintf('\n')
% end
save([F,'Quant.mat'],'spk_t','clust_type','shank','channel','rezInds','clusts');