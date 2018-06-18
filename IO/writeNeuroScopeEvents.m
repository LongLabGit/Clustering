function writeNeuroScopeEvents(outFileName, spikeTimes, clusterIDs)
%Writes an evt files for neuroscope
% spikeTimes is in ms
% format of file is ***.abc.xyz dont ask me while. for example,
% clusters.spk.evt
% cluster id is a numerical vector
outFile = fopen(outFileName,'w');
for i = 1:length(spikeTimes)
    fprintf(outFile,'%.2f sf%.2f\n',[spikeTimes(i), clusterIDs(i)]); % in ms
end
fclose(outFile);