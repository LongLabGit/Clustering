 % Load Data
reboot;
addpath Fcns
addpath ../Fcns/BrendonIO
F='S:/Vigi/NeuroGrid/Data/338A/Recording/Session1_Denoised/batches/';
load([F,'KS_Output.mat'],'rez');
load([F,'Quant.mat']);
load([F,'Scores.mat']);
load([F,'rawV.mat']);
set(0,'DefaultFigureWindowStyle','docked')
%% Probe info
IED=load('..\LFP\IEDs\finalT.mat');tIED=IED.tRfinal(IED.id2==2)/1250;clear IED;%load IEDs
load ..\Probe\AnatGroup.mat
e2=floor(eLoc/1.89)*3+ceil(mod(eLoc,1.89));%
chanMap=[AnatGroup{:}]+1;
e2=e2(chanMap,:);
%%
for c=1:length(clusts)
    figure(c);clf;
    ts=spk_t{c};
    %WaveForms
    subplot(2,3,[1,4]);
    plot_avgs(squeeze(shape(:,:,c)),e2,channel(c));%plot waveform
    title(['Shank ' num2str(shank(c)) '/Channel ' num2str(chanMap(channel(c))-1)  ', amp= ' num2str(summary.ampV(c),2) '\muV'])

    subplot(2,3,2);
    IED_triggeredAvg(ts/20,tIED*1e3);
    title(['IED, z=' num2str(summary.ied_z(c),2)])

    
    subplot(2,3,5);
    amplitude_trace(ts/2e4/60,rez.st3(rezInds{c},3),spk_amp{c},rez.ops.Th(end))
%     title(['Amplitude Trace, IrrZ=' num2str(summary.IR_ratio(c),2), ', Trunc=' num2str(summary.below_thresh(c)*100,2), '%'])
    title(['Amplitude Trace, IrrZ=' num2str(summary.IR_ratio(c),2)])
    
    subplot(2,3,3);
    pk=auto_corr(spk_t{c},.030,.0003);
    title(['Autocorr, peak @' num2str(pk) 'ms, fast=' num2str(summary.percFast(c)*100,2), '%'])
    subplot(2,3,6);
    plotEx(rez.ops.fbinary,ts,chanMap(channel(c)),squeeze(shape(:,:,c)));
%     title(['Example Subset, SNR=' num2str(summary{c,12},2)])
    suptitle(sprintf('Cell #%i/Clust #%i (%.1f Hz)',[c,clusts(c),length(ts)/range(ts)*2e4]))
%     orient landscape
%     print -fillpage
end