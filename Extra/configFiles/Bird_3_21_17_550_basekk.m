%Some Probe Stuff. Do not change
edit(id);%open it for you so that you can make sure you are using the correct one
cd ../../
ops.root='S:/Vigi/SiProbe/Data/3_21_17/550_baseline_KwikKast/';
ops.fbinary=[ops.root,'amplifier.dat'];
ops.fproc=[ops.root,'temp_wh.dat'];
ops.datatype            = 'dat';  % binary ('dat', 'bin') or 'openEphys'
ops.NchanTOT            = 64; %384;   % total number of channels
ops.fs                  = 20000; % sampling rate
ops.chanMap =  'Extra/ChanMaps/Bird2-8.mat';
load(ops.chanMap,'connected')
ops.Nchan               = sum(connected>1e-6); % number of active channels 

%Some Settings to play with 
ops.Nfilt               = 256; %  number of filters to use (512, should be a multiple of 32)
ops.criterionNoiseChannels= .2; %

% these options can improve/deteriorate results. when multiple values are @
% provided for an option, the first two are beginning and ending anneal values, 
% the third is the value used in the final pass. 
%The three values correspond to 1) start of optimization 2) end of optimization 3) final template matching and subtraction step.
ops.Th               = [6 13 13];    % threshold for detecting spikes on template-filtered data ([6 12 12]) 
%It's simply a threshold on the convolution of the template (mean cell waveform) with the raw signal.
%MARIUS ops.Th               = [2 12 12] ; %[4 12 12];    % threshold for detecting spikes on template-filtered data ([6 12 12])
ops.lam              = [10 30 30];   % large means amplitudes are forced around the mean ([10 30 30])
%a trade-off between the mean squared error of the raw data reconstruction term  and the squared 
%error between the amplitude of the spike and the mean amplitude for that template. For example, 
%when lam  = Inf, spikes from the same template always have the same amplitude. When lam is set to 
%0, the amplitude from the same template can be anything (but the spatiotemporal shape has to be consistent). 
%MARIUS ops.lam              = [1 5 5];   % large means amplitudes are forced around the mean ([10 30 30])

ops.GPU                 = 1; % whether to run this code on an Nvidia GPU (much faster, mexGPUall first)
ops.parfor              = 1; % whether to use parfor to accelerate some parts of the algorithm
ops.verbose             = 1; % whether to print command line progress
ops.showfigures         = 0; % whether to plot figures during optimization



%Some Basic stuff
ops.Nrank               = 3;    % matrix rank of spike template model (3)
ops.nfullpasses         = 6;    % number of complete passes through data during optimization (6)
ops.nannealpasses    = 4;            % should be less than nfullpasses (4)
ops.momentum         = 1./[20 400];  % start with high momentum and anneal (1./[20 1000])
ops.shuffle_clusters = 1;            % allow merges and splits during optimization (was 0)
ops.mergeT           = .1;           % upper threshold for merging (.1) 1-correlation.
ops.splitT           = .1;           % lower threshold for splitting (.1). tries to fit bimodal distribution to amps

ops.maxFR               = 20000;  % maximum number of spikes to extract per batch (20000) %INCREASE THIS
ops.fshigh              = 300;   % frequency for high pass filtering
ops.fslow              = 10000;   % frequency for high pass filtering
ops.ntbuff              = 64;    % samples of symmetrical buffer for whitening and spike detection
ops.scaleproc           = 200;   % int16 scaling of whitened data keep this at 200. otherwise gets a lot of zeros
ops.NT                  = 128*1024+ ops.ntbuff;% this is the batch size, very important for memory reasons. 
% should be multiple of 32 (or higher power of 2) + ntbuff



ops.nNeighPC    = 8; %12; % number of channnels to mask the PCs, leave empty to skip (12)
ops.nNeigh      = 8; % number of neighboring templates to retain projections of (16)

% Spike Templates
ops.initialize = 'fromData'; %'fromData' or 'no'. If no, puts a filter on each channel,. if yes, biases towards electrodes with more spikes
dd                  = load('PCspikes2.mat'); % you might want to recompute this from your own data.
ops.wPCA            = dd.Wi(:,1:7);   % PCs 
% options for initializing spikes from data
ops.spkTh           = -3;      % spike threshold in standard deviations (4)% was 6. 
ops.loc_range       = [3  1];  % ranges to detect peaks; plus/minus in time and channel ([3 1])%to be defined as max
ops.long_range      = [30  6]; % ranges to detect isolated peaks ([30 6])%to be defined as a spike
ops.maskMaxChannels = 5;       % how many channels to mask up/down ([5]). like flood fill on KK2
ops.crit            = .65;     % upper criterion for discarding spike repeates (0.65)
ops.nFiltMax        = 10000;   % maximum "unique" spikes to consider (10000)

%for posthoc merges
ops.fracse  = 0.1; % binning step along discriminant axis for posthoc merges (in units of sd)
ops.epu     = Inf;

ops.whitening           = 'full'; % dont change this! type of whitening (default 'full', for 'noSpikes' set options for spike detection below)
ops.nSkipCov       = 1; % compute whitening matrix from every N-th batch
ops.whiteningRange = 10; % how many channels to whiten together (Inf for whole probe whitening, should be fine if Nchan<=32)

ops.ForceMaxRAMforDat   = 20e9; %20e9;  % maximum RAM the algorithm will try to use

batch_path = fullfile(ops.root, 'batches');
if ~exist(batch_path, 'dir')
    mkdir(batch_path);
end
clear dd connected batch_path id;