clear;clc;close all;
F='S:\Arka\SingingMice\SiProbe\3_5\scot_6\batches\';
cols=lines(7);
%% Plot Location
load S:\Vigi\Matlab\SiProbe\Probe\AnatGroup.mat;
figure(1);clf;hold on;
for g=2:8
    inds=AnatGroup{g}+1;
    plot(eLoc(inds,1),eLoc(inds,2),'s','MarkerFaceColor',cols(g-1,:))
end
xlabel('mm')
ylabel('mm')
axis square
axis equal
axis tight
xlim([150,1450])
ylim([-50,190])
%% Plot Spikes
figure(2);clf;hold on;
load([F,'Quant.mat'])
[shank,inds]=sort(shank);
spk_t=spk_t(inds);
clusts=clusts(inds);
tStart=50*60;%CHANGE THIS NUMBER
tStop=tStart+2;%CHANGE THIS NUMBER
ind=0;
for c=1:length(spk_t);
    spks=spk_t{c}/2e4;
    shankI=shank(c);
    inds=spks>tStart&spks<tStop;
    spks=spks(inds)-tStart;
    if length(spks)~=2&&~isempty(spks)
        line(spks*[1,1],ind+[.08,.92],'color',cols(shankI-1,:))
        ind=ind+1;
    elseif length(spks)==2
        line(spks(1)*[1,1],ind+[.08,.92],'color',cols(shankI-1,:))
        line(spks(2)*[1,1],ind+[.08,.92],'color',cols(shankI-1,:))
        ind=ind+1;
    end
    FR(c)=length(spks)/(tStop-tStart);
end
xlabel('time (s)')
ylabel('cluster number')
title(['Spontaneous Activity, tStart=' num2str(tStart/60) ' minutes'])
set(gca,'ydir','reverse')
%% Plot Histogram
figure(3);
spks=vertcat(spk_t{:})/2e4;
bw=20;%seconds
bins=1:bw:max(spks);
m=histcounts(spks,bins);
m=smooth(m/bw/length(spk_t));
plot(bins(2:end)/60,m)
xlabel('time (m)')
axis tight
ylabel('Mean FR (hz) of all 63 clusters')
title('Effect of time on # of single unit spikes acquired')
savefig(1:3,'GreatScot.fig')