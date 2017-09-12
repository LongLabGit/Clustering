reboot;
addpath(genpath('Extra'))
addpath(genpath('KiloSort'))
%Here define the file that you want
F='S:/Vigi/NeuroGrid/Data/338A/Recording/Session1_Denoised/batches/';
load S:\Vigi\Matlab\NeuroGrid\Probe\AnatGroup
load S:\Vigi\Matlab\NeuroGrid\LFP\IEDs\spikeNwav.mat
load([F,'Quant.mat']);
nSpikes=cellfun(@length,spk_t);
channel=channel(strcmp(clust_type,'good'));
nSpikes=nSpikes(strcmp(clust_type,'good'));
%% set up some stuff
v1=[1,1,1,1;
    2,1,1,0;
    0,1,2,1;
    0,0,0,2;
    0,0,0,0;
    2,1,2,1;
    2,1,1,0
    0,1,1,1];
v2=[1,0,0,0;
    2,0,1,1;
    0,2,2,2;
    0,0,0,2;
    0,0,1,0;
    2,1,2,1;
    2,1,0,0
    1,1,1,1];
vessels=(v1+v2)/2;
vessels=kron(vessels,[1,1;1,1]);%spread it out.
vessels(1,:)=[];
vessels=2-vessels;
vessels=fliplr(vessels);%make it grid oriented for now, well switch back later
c_perChannel=histcounts(channel,.5:120.5);
chanC=c_perChannel(sorted_map+1);
for i=1:120;
    s_perChannel(i)=sum(nSpikes(channel==i));
end
max(s_perChannel/600)
s_perChannel(s_perChannel>3e4)=3e4;
hz=s_perChannel/600;
hz=hz(sorted_map+1);
Iamp=amp(map+1);
%% Plot locs
figure(1);clf;
subplot(1,2,1)
imagesc(chanC)
title('channels with a cluster')
boyRobot(1);
mapEdges;
subplot(1,2,2);
imagesc(hz)
boyRobot(1);
mapEdges;
colorbar;
title('Hz per channel (upper limit = 50 Hz)')
%% plot anatomy
figure(2);clf;
subplot(1,2,1);
imagesc(Iamp);
colormap bone
boyRobot(1);
mapEdges;
colorbar;
title('IED Amplitude')

subplot(1,2,2);
imagesc(fliplr(vessels));
boyRobot(1);
mapEdges;
cb=colorbar;
cb.Ticks=[0,2];
cb.TickLabels={'Vessel','Brain'};
title('Anatomy')
%% compare characteristics
% figure(3);clf;
% subplot(1,2,2);
% plot(vessels(hz>0),hz(hz>0)/50*100,'o');%percentage of 50hz.
% hold on
% pC=nan(1,3);
% for i=0:2
%     pC(i+1)=sum(chanC(vessels==i))/length(chanC(vessels==i));
%     pC(i+1)=sum(chanC(vessels==i))/length(chanC(vessels==i))*100;
% end
% plot(0:2,pC,'rx','markerSize',15);
% xlim([-.5,2.5]);set(gca,'xtick',0:2);set(gca,'xticklabel',{'vein','?','brain'});
% legend('% of max firing rate','% of clusters with a neuron')
% ylabel('Percentage')
% title('Matching Clusters to Veins')
% ylim([0,100])
% subplot(1,2,1);
% Iamp2=Iamp>100;
% plot(Iamp2(hz>0),hz(hz>0)/50*100,'o');%percentage of 50hz.
% ylabel('Percentage')
% hold on
% pC=nan(1,2);
% for i=0:1
%     pC(i+1)=sum(chanC(Iamp2==i))/length(chanC(Iamp2==i));
%     pC(i+1)=sum(chanC(Iamp2==i))/length(chanC(Iamp2==i))*100;
% end
% plot(0:1,pC,'rx','markerSize',15);
% xlim([-.5,1.5]);set(gca,'xtick',0:1);set(gca,'xticklabel',{'no ied','yes ied'});
% legend('% of max firing rate','% of clusters with a neuron')
xlabel('IED Presence')
title('Matching Clusters to IEDs')
ylim([0,100])