function [SamplingInterval, AnalogVoltage] = loadAnalogSignalIntan(SiProbePath, analogFilename)

frequency_parameters = read_Intan_RHD2000_frequency_parameters([SiProbePath,'info.rhd']);%This will just spit out details

SamplingInterval = 1.0/frequency_parameters.amplifier_sample_rate;
% num_channels = length(board_adc_channels); % ADC input info from header file
num_channels = 1; % ADC input info from header file
fileinfo = dir([SiProbePath, analogFilename]);
num_samples = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes
fid = fopen([SiProbePath, analogFilename], 'r');
v = fread(fid, [num_channels, num_samples], 'uint16');
fclose(fid);
v = v * 0.000050354; % Magic number - convert to volts
AnalogVoltage = v(1,:);

end