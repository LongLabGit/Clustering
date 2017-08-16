
%% get info on your data
clear;clc;close all;
% addpath('Fcns\Intan\')
SiProbePath = 'Z:\Robert\INT_connectivity\SiProbe\PracticeBird_020717\SiProbe\baseline_170207_174445\';
read_Intan_RHD2000_file([SiProbePath,'info.rhd']);%This will just spit out details

SiProbeSamplingInterval = 1.0/frequency_parameters.amplifier_sample_rate;
num_channels = length(board_adc_channels); % ADC input info from header file
fileinfo = dir([SiProbePath,'analogin.dat']);
num_samples = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes
fid = fopen([SiProbePath,'analogin.dat'], 'r');
v = fread(fid, [num_channels, num_samples], 'uint16');
fclose(fid);
v = v * 0.000050354; % Magic number - convert to volts
ttlPulseSiProbe = v(1,:);

WholeCellName = 'Z:\Robert\INT_connectivity\SiProbe\PracticeBird_020717\WholeCell\cell1_0000.abf';
[d,si,h] = abfload(WholeCellName);
WholeCellSamplingInterval = si*1e-6;
% WholeCellSamplingInterval = 18*1e-6;
i = squeeze(d(:,1,:))';
v = squeeze(d(:,2,:))';
ttlPulseWholeCell = squeeze(d(:,4,:))';
nSweeps = size(d,3);

%% compare TTL signals Intan/AxoClamp
figure(1);
hold on;
SiProbeTime = SiProbeSamplingInterval*(1:length(ttlPulseSiProbe));
WholeCellTime = WholeCellSamplingInterval*(1:length(ttlPulseWholeCell));
plot(SiProbeTime, ttlPulseSiProbe, 'k');
plot(WholeCellTime, ttlPulseWholeCell, 'r');
hold off;

pulseThreshold = 1.0;
[SiProbePulses, SiProbeIndices] = detectThresholdCrossings(SiProbeTime, ttlPulseSiProbe, pulseThreshold);
[WholeCellPulses, WholeCellIndices] = detectThresholdCrossings(WholeCellTime, ttlPulseWholeCell, pulseThreshold);

pulseInterval = 0.1;
dnSi = SiProbeIndices(2) - SiProbeIndices(1);
dnWC = WholeCellIndices(2) - WholeCellIndices(1);
dnSiNominal = pulseInterval/SiProbeSamplingInterval;
dnWCNominal = pulseInterval/WholeCellSamplingInterval;

% dt = SiProbePulses(1) - WholeCellPulses(1);
% WholeCellPulsesAligned = WholeCellPulses + dt;
SiProbePulsesAligned = SiProbePulses - SiProbePulses(1);
WholeCellPulsesAligned = WholeCellPulses - WholeCellPulses(1);
%%
figure(2);
hold on;
plot(SiProbePulsesAligned, WholeCellPulsesAligned, 'r+');
plot(SiProbePulsesAligned, SiProbePulsesAligned, 'k');
hold off;

scaleFactors = WholeCellPulsesAligned./SiProbePulsesAligned;

%% align whole cell trace to SiProbe trace
alignment = fit(WholeCellPulses', SiProbePulses', 'poly1');
figure(3);
hold on;
plot(SiProbeTime, ttlPulseSiProbe, 'k');
plot(alignment(WholeCellTime), ttlPulseWholeCell, 'r');
hold off;

