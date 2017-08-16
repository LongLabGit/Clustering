function [WholeCellCurrents] = loadWholeCellData(fileNames, channels)

% loads abf files given in cell array fileNames and returns channels specified
% for each file, and adds time axis as last row
% requires abfload

for i = 1:length(fileNames)
    WholeCellCurrents(i).fileName = fileNames{i};
    [data, samplingInterval, h] = abfload(fileNames{i});
    WholeCellSamplingInterval = samplingInterval*1e-6;
    channelData = [];
    for j = 1:length(channels)
        channel = channels(j);
        channelData = [channelData; squeeze(data(:, channel, :))'];
    end
    timeAxis = WholeCellSamplingInterval*(0:(length(channelData(1,:)-1)));
    WholeCellCurrents(i).data = channelData;
    WholeCellCurrents(i).time = timeAxis;
end

end