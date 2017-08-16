function writeNeuroScopeEvents(outFileName, spikeTimes, clusterIDs)

outFile = fopen(outFileName,'w');
for i = 1:length(spikeTimes)
    fprintf(outFile,'%.2f cluster%i\n',[spikeTimes(i), clusterIDs(i)]); % in ms
end
fclose(outFile);

end