function NSclusterFiles(F,anatGroup,spikeTimes,clusters)
%This will make you paired clu and res files that neuroscope can read in
%   F: folder where it will write them
%   anatGroup: you need to do this for each set of electrodes. the
%       anatGroup needs to match the NS anatomical groups so that NS knows
%       which traces to color in
%   spikeTimes: times in SAMPLES!!! of all your spikes. note: this MUST be
%       sorted in order
%   clusters: this is a Nx1 vector of cluster IDs for the corresponding
%      spikeTimes
clustF=[F,'clusters.clu.' num2str(anatGroup)];
resF=[F,'clusters.res.' num2str(anatGroup)];
%neuroscope wants the # of clusters first. no one knows why. SAD!!
clusters=[length(unique(clusters));clusters];

dlmwrite(clustF,clusters,'delimiter','\n','precision','%d');
dlmwrite(resF,spikeTimes,'delimiter','\n','precision','%d');