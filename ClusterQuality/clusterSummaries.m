function clusterSummaries(clusters)
%% Count them
groups={clusters.group};
keep=unique(groups);
for i=1:length(keep)
    disp(['# of ' keep{i} ': ' num2str(sum(strcmp({clusters.group},keep{i})))])
end
%% Cell classes?
figure(1);clf;
sw=vertcat(clusters.spikeW);
fr=[clusters.FR];
sw=sw(:,3);
plot(fr,sw,'o')
xlabel('FR (Hz)')
ylabel('spike width (ms)')
if length(groups)>1
    inds=strcmp(groups,'good');
    hold on;
    plot(fr(inds),sw(inds),'o')
    legend('bad','good')
end
title('Distribution of Firing Rates vs Spike Width')
%% Quality Scores
figure(2);clf;
i=[clusters.Isolation];
l=[clusters.LRatio];
fp=vertcat(clusters.fpRate);
subplot(1,2,1)
plot(i,l,'o')
xlabel('Isolation score')
ylabel('L Ratio')
if length(groups)>1
    inds=strcmp(groups,'good');
    hold on;
    plot(i(inds),l(inds),'o')
    legend('bad','good')
end
title('Cluster Distances (Waveform Based)')
set(gca,'yscale','log')
set(gca,'xscale','log')
subplot(1,2,2)
plot(fp(:,1),fp(:,end),'o')
xlabel('short false positive (1 ms)')
ylabel('long false positive (2 ms)')
if length(groups)>1
    inds=strcmp(groups,'good');
    hold on;
    plot(fp(inds,1),fp(inds,end),'o')
    legend('bad','good')
end
title('Contamination (Spike Time Based)')
suptitle('Quality Scores')