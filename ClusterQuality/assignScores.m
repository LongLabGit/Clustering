function clusters=assignScores(folder,clusters,probe,ampFile)
%This will add a whole bunch of meta info to your clusters. Robert hates it
%because hes an angry old man
if isempty(ampFile)
    dat_file=probe.dat_file;
else
    dat_file=[folder,ampFile];
end

%WAVEFORM
disp('Loading waveforms. This takes a bit because we are loading from the raw data')
baseI=1e3;%indices of the baseline. it accounts to 10 samples (because we are upsamplign x100)
nSamp=5e2;%number of spikes. lower this number to run faster
for c=1:length(clusters)
    nC=probe.nchan;
    chan=clusters(c).maxChannel+1;
    spikes=round(clusters(c).spikeTimes*probe.fs);
    win=ceil([-probe.nt0*1/3,probe.nt0*2/3]);
    [w, ~]=readWaveformsFromDat(dat_file,nC,chan,spikes,win, nSamp);
    w=w-median(w);
    %Now get stats about it
    tO=(win(1):win(2))/probe.fs;%original time scale
    tN=(win(1):.01:win(2))/probe.fs;%new time scale
    wN= interp1(tO,w,tN);%upsample the waveform
    base = median(wN(1:baseI));
    [minV, minBin] = min(wN);
    [maxV, maxBin] = max(wN(minBin:end));
    maxBin = maxBin + minBin-1;
    
    below1 = wN < (0.5*(base + minV));%find the indices below halfway of base to min
    below2 = wN < (0.5*(maxV + minV));%find the indices below halfway of min to max
    below2(1:find(wN<min(wN(1:baseI)),1,'first'))=0;%need to account for the fact that this trehsold might be abbovebaseline. If so, start counting form the dip down
    
    %Store it
    %waveform
    clusters(c).waveform=w;
    %halfW if height is min to base, halfW  if height is min to max, time range min to max
    clusters(c).spikeW=[range(tN(below1)) , range(tN(below2)),tN(maxBin)-tN(minBin)]*1e3;
    %range of base to min,max to min
    clusters(c).spikeA=[base-minV,(maxV -minV)];
    fprintf('%i,',c)
end
disp('done with waveforms')

disp('Calculating firing rate properties')
%Calculate ISI violations
minISI = [1,1.5,2]/1e3;%These will be 
for c=1:length(clusters)
    fpRate=nan(1,length(minISI));
    for i=1:length(minISI)
        [fpRate(i),~]=ISIViolations(clusters(c).spikeTimes, 1/probe.fs, minISI(i));
    end
    clusters(c).fpRate=fpRate;
end
for c=1:length(clusters)
    spkT=clusters(c).spikeTimes;
    isi=diff(spkT);
    clusters(c).FR=length(spkT)/range(spkT);
    clusters(c).isi_cv=std(isi)/mean(isi);
end

disp('Calculating Quality Score')
%Cluster Scores
[allClusterIDs, unitQuality, contaminationRate, LRatio] = sqKilosort.maskedClusterQuality(folder);
for c=1:length(clusters)
    ind=(allClusterIDs - 1)==clusters(c).clustID;
    clusters(c).Isolation=unitQuality(ind);
    clusters(c).contaminationRate=contaminationRate(ind);
    clusters(c).LRatio=LRatio(ind);
end