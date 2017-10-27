reboot;
addpath Fcns
addpath S:\Vigi\Matlab\GitHub\Clustering\IO
addpath S:\Vigi\Matlab\GitHub\Clustering\ClusterQuality
addpath(genpath_exclude('S:\Vigi\Matlab\GitHub\sortingQuality',{'\+sqKilosort','\+sqKwik','\.git'}));
addpath S:\Vigi\Matlab\GitHub\Clustering\Extra\npy-matlab
%%
folder='S:\Vigi\Datasets\SiliconProbe\InterneuronContext\SingingListening\cut\';
[clusters,probe] = loadKS(folder, 'dev',{'good','mua'},2e4);
clusters = assignScores(folder,clusters,probe,'cut_amplifier.dat');
clusterSummaries(clusters)
save([folder,'clusters.mat'],'clusters')