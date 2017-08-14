reboot;
addpath(genpath('S:\Vigi\Matlab\OtherClustering\KiloSort'))
addpath(genpath('Extra'))
addpath Fcns
gpuDevice(1);
%% Run the core
%Here define the file that you want
id='MargotRA.m';run(fullfile('Extra/configFiles/',id));
[rez, DATA, uproj] = preprocessData(ops);
rez=fitTemplates(rez, DATA, uproj); 
save('D:\Margot\rez.mat','rez');
%%
rez=fullMPMU(rez,DATA);
% rez = merge_posthoc2(rez);%would be nice, but screws up clustering later. do for baseline
rezToPhyV(rez,ops);
