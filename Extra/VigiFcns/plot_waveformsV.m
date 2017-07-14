function plot_waveformsV(rez,clusts,s,Wraw)
close all;
% load('S:\Vigi\Matlab\NeuroGrid\LFP\IEDs\finalT.mat','id2','tRfinal');
set(0,'DefaultFigureWindowStyle','docked')
ops=rez.ops;

if nargin<3
    s=[];
    Wraw=[];
end

if isempty(clusts)
    clusts=1:ops.Nfilt;
end

cdf=1;
for k =clusts
    ik = find(rez.st3(:,2)==k);
    if length(ik)>5
        figure(k);clf;
        colormap('parula')
        subplot(1,3,1)
        wa = squeeze(rez.U(:,k,:)) * squeeze(rez.W(:,k,:))';
%         wa=squeeze(rez.Wraw(:,:,k));
        wa = 200 * wa;
%         wa=rez.WrotInv*wa;
        mW=wa(:,21:end);
        t=(1:size(mW,2))/ops.fs*1e3;
        imagesc(t,(1:size(mW,1)),mW)
        if ischar(rez.ops.chanMap)
            load(ops.chanMap,'kcoords','connected')
            kcoords=kcoords(logical(connected));
            demarcations=find(diff([kcoords,0]))+.5;
            for i=1:(length(demarcations)-1)
                line(xlim,demarcations(i)*[1,1],'linewidth',2,'color','k');
            end
            ylocs=demarcations-diff([0,demarcations])/2;
            set(gca,'ytick',ylocs)
            set(gca,'yticklabel',strread(num2str(1:(length(demarcations)+1)),'%s'))
        end

        ylabel('Shank')
        title('mean waveform')
        xlabel('time (ms)')
        axis tight
        
        if cdf
            subplot(2,3,2)
            m = sort(rez.st3(ik,3), 'descend');%amplitudes
            plot(m,'linewidth',2)
            xlabel('sorted spikes')
            ylabel('amplitudes')
            title('CDF of Amplitude')
            axis tight
        else
            subplot(2,3,2);hold on;
            [times,~]=timeLock(rez.st3(ik,1)/20,tRfinal(id2==2)/1.25,[-250,400]);%turn both into ms
            histogram(times,-250:10:400,'normalization','probability','displaystyle','stairs');
%             [times,~]=timeLock(rez.st3(ik,1),tRfinal(id2==3)/1.25,[-250,400]);
%             histogram(times,-250:20:400,'normalization','probability','displaystyle','stairs');
            xlabel('time (ms)')
            ylabel('P(spike)')
            title('IED Triggered Average')
            axis tight
%             legend('Classic','Sharp')
        end
        if ~isempty(s)
            subplot(2,3,5)
            plot(Wraw(:,:,k),'linewidth',2)
            xlabel('time sample')
            ylabel('voltage (\muV)')
            title('mean waveform')
            axis tight
            subplot(2,3,3)
            Mmax=max(abs(wa), [], 2);%get the max amplitude in each channel
            [~, ichan] = max(Mmax);
            imagesc(squeeze(s{k,2}(:,:,ichan))')
            ylabel('spike index')
            xlabel('time sample')
            title('Waveform Stability')
            axis tight
            subplot(2,3,6)
            amp=max(squeeze(s{k,2}(:,:,ichan)));
            plot(s{k,1}/ops.fs,amp,'.');
            maxAmp(k)=mean(amp);
        else
            subplot(2,3,5)
            plot(t,wa(:,21:end)')
            xlabel('time (ms)')
            ylabel('voltage (\muV)')
            title('mean waveform')
            axis tight
            tSpike=rez.st3(ik,1)/ops.fs;
            subplot(2,3,6)
            maxAmp(k)=mean(rez.st3(ik,3));
            plot(tSpike,rez.st3(ik,3),'.');
            axis tight;
            xlabel('time (s)')
            ylabel('amplitude (\muV)')
            title('Spike Raster')
            yy=ylim;
            ylim([0,yy(2)])
            %Do Xcorr
            subplot(2,3,3)
            width=.03;%in s
            binSize=.0003;%in s
            newFs=1/binSize;
            % resample at a lower Fs in tune with bins
            Sinds=round(tSpike*newFs);
            tSpike2=zeros(1,max(Sinds));%this is more memory intensive but faster than a for loop
            tSpike2(Sinds)=1;
            [c,lags]=xcorr(tSpike2,newFs*width);
            c(ceil(end/2))=NaN;
            c=c/max(c);
            plot(lags*binSize*1e3,c)
            xlabel('time (ms)')
            ylabel('corr')
            title('AutoCorrelogram')
            axis tight;
            yy=ylim;
            ylim([0,yy(2)]);
        end
        if isfield(rez,'shank')
            suptitle(sprintf('cluster #%d, shank #%d', k,rez.shank(k)))
        else
            suptitle(sprintf('cluster #%d', k))
        end
    end
end
