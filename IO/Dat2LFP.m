function Dat2LFP(datFile,nChannels,up,down)
%ResampleBinary - Resample binary data file.
% Stolen from buzcode/externalPackages/FMAToolbox/IO/ResampleBinary.m
% Resample binary data file, e.g. create LFP file from raw data file.
%
%  USAGE
%
%    Dat2LFP(inputName,outputName,nChannels,up,down)
%
%    datFile        binary input file
%    nChannels      number of channels in the file
%    up             upsampling integer factor
%    down           downsampling integer factor
%
%  NOTE
%
%    The actual resampling ratio is up/down.

% Copyright (C) Vigi who stole it from the buzsaki lab


% Open input file and output file
inputFile = fopen(datFile,'r');
outputFile = fopen(strrep(datFile,'.dat','.lfp'),'w');

%
bufferSize = 2^16  - mod(2^16,down); % 16 or 12?
% Number of overlapping points per channel in the resampled signal
% (chosen so that both resampledOverlap and originalOverlap are integers)
resampledOverlap = 8*up;
% Number of overlapping points per channel in the original signal
originalOverlap = resampledOverlap * down/up;

% Read first buffer
overlapBuffer= fread(inputFile,[nChannels,originalOverlap],'int16');
overlapBuffer = fliplr(overlapBuffer);
frewind(inputFile);
dataSegment = fread(inputFile,[nChannels,bufferSize],'int16');
dataSegment2 = [overlapBuffer,dataSegment]';
resampled = resample(dataSegment2,up,down);
fwrite(outputFile,resampled(resampledOverlap+1:size(resampled,1)-resampledOverlap/2,:)','int16');
overlapBuffer = dataSegment2(size(dataSegment2,1)-(originalOverlap-1):size(dataSegment2,1),:);

% Read subsequent buffers
while ~feof(inputFile)
  dataSegment = fread(inputFile,[nChannels,bufferSize],'int16');
  dataSegment2 = [overlapBuffer;dataSegment'];
  resampled = resample(dataSegment2,up,down);
  fwrite(outputFile,resampled((resampledOverlap/2+1):size(resampled,1)-resampledOverlap/2,:)','int16');
  overlapBuffer = dataSegment2(size(dataSegment2,1)-(originalOverlap-1):size(dataSegment2,1),:);
end

% Add the last unprocessed portion
resampled = resample(overlapBuffer,up,down);
fwrite(outputFile,resampled((resampledOverlap/2+1):end,:)','int16');

fclose(outputFile);
