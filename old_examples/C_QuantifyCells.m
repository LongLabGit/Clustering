reboot;
addpath ..\Fcns\BrendonIO
addpath Extra\VigiFcns
addpath Fcns
%set file
F='S:/Vigi/NeuroGrid/Data/338A/Recording/Session1_Denoised/batches/';
%load priors
load ../LFP/IEDs/spikeNwav.mat tIED
load ../Probe/AnatGroup.mat AnatGroup
load ../Denoising/LineTimes.mat tLine
load ../Denoising/NoiseICA.mat;
%load data
load([F,'KS_Output.mat'],'rez');
load([F,'Quant.mat']);
clc;
%% params
minISI=2e-3;%min isi for violations
Irr_time=[4.83,5.06]*60*2e4;%this is the range of irrigation.
bw=.001;
% set up
lastSpike=max(vertcat(spk_t{:}));
chanMap=[AnatGroup{:}]+1;
Thra=Thra(chanMap,:);
keep=Ta<(lastSpike/2e4/60);%cut off analysis point
noiseICA=median(Thra(:,keep),2);
tLine=tLine(chanMap,:);%this only goes until 10 minutes anyways
keep=any(tLine<lastSpike);
tLine=tLine(:,keep);
%% Histogram Based
[percFast,isi,ied_z,IR_ratio,LineNoise,LineNoiseW]=deal(nan(length(clusts),1));%initialie
for i=1:length(spk_t)
    ts=spk_t{i};
    %isi based
    isi=diff(ts)/2e4;
    percFast(i)=sum(isi<minISI)/length(isi);
    %IED modulation
    times=timeLock(ts/2e4,tIED,[-.5,.5]);
    [n,bins]=histcounts(times,-.5:bw:.2);
    bins=bins(1:end-1)+bw/2;
    %baseline
    m=mean(n(bins<-.2));
    s=std(n(bins<-.2));
    l=mean(n(bins>.035));%slow was is 35 to 200 see paper ?? which paper dammit 
    ied_z(i)=(l-m)/s;%z score
    %check irrigation
    nDuring=sum(ts<Irr_time(2)&ts>Irr_time(1));
    nBins=range([min(ts),Irr_time(1)])/range(Irr_time);
    bins=linspace(min(ts),Irr_time(1),nBins);
    try 
        n=histcounts(ts(ts<Irr_time(1)),bins);
    catch
        n=zeros(size(bins));
    end
    IR_ratio(i)=(nDuring-mean(n))/std(n);
    %check lines
    if length(ts)<5e3%memory intensive speedup
        D = pdist2(ts,tLine(channel(i),:)');
        d=min(D,[],2)';  
    else
        d=zeros(1,length(ts));
        for ii=1:length(ts)
            d(ii)=min(abs(ts(ii)-tLine(channel(i),:)));
        end
    end
    LineNoise(i)=sum(d==0)/length(d)*(length(unique(d))-1);%percetage of it that overlaps
    LineNoiseW(i)=sum(d<=1)/length(d)*(length(unique(d))-1);%percetage of it that overlaps
end
nSpike=cellfun(@length,spk_t);
%% get from raw data
% v=LoadBinary(rez.ops.fbinary,'nChannels',120,'channels',1:120,'start',0,'duration',Inf)';%this takes it from analysed dat. might want to look at .fil too
% v=v(chanMap,:);%KEEP IT AS INT16
% noise=1.4826*mad(v',1);
%% Quantify Waveforms
t_inds=-40:40;
[ampV,snr,fwhm,spikeSym,trough_latency]=deal(nan(length(clusts),1));
shape=zeros(120,length(t_inds),length(spk_t));
spk_amp=cell(length(spk_t),1);
%quantify it
for i=1:length(spk_t)
    ts=spk_t{i};
    [meanWF,allWF]=readWaveformsFromDat(rez.ops.fbinary, 120, ts, [-40,40], []);
    meanWF=meanWF(chanMap,:,:)*.195;
    allWF=allWF(chanMap,:,:)*.195;
    c=channel(i);
    wf=meanWF(c,:);
    ampV(i)=-min(wf);
    snr(i)=-min(wf)/noiseICA(c);
    fwhm(i)=find(wf(t_inds>=0)>.5*min(wf),1,'first')*2/20;
    a=min(wf(t_inds<0)*sign(wf(t_inds==0)));%amplitude and location of lobe 2
    [b,late]=min(wf(t_inds>0)*sign(wf(t_inds==0)));%amplitude and location of lobe 2
    spikeSym(i)=(a-b)/(a+b);
    trough_latency(i)=late/20;
    spk_amp{i}=squeeze(allWF(c,t_inds==0,:));
    shape(:,:,i)=meanWF;
end
%%
% put it all in a table 
summary=table(clusts,shank,channel,nSpike,percFast,LineNoise,LineNoiseW,...
    ied_z,IR_ratio,ampV,snr,spikeSym,fwhm,trough_latency);
save([F,'Scores.mat'],'summary')
save([F,'rawV.mat'],'shape','spk_amp')
% put it all in a table 
%% Plot Summaries
%FLIPLR
figure(2);
%location of spikes
subplot(2,2,1)
imagesc(totS(flipud(reshape(1:32,8,4))))
colorbar
title('# of spikes')
%location of clusters
subplot(2,2,2)
imagesc(totC(flipud(reshape(1:32,8,4))))
title('# of clusters')
colorbar
%firing rates
subplot(2,2,3)
hz=cellfun(@length,spk_t)/range(vertcat(spk_t{:}))*2e4;
histogram(hz,20)
xlabel('Hz')
ylabel('# of Neurons')
title('Firing Rates')
%amplitudes
subplot(2,2,4)
nSpike=cellfun(@length,spk_t);
histogram(snr,20)
xlabel('SNR')
ylabel('# of Neurons')
title('SNR')
% suptitle('Summary Statistics')