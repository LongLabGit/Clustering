%% Bird
reboot;
load ../../../../SiProbe/Probe/AnatGroup.mat
nChannels=64;
chanMap=[AnatGroup{:}]+1;
chanMap0ind=chanMap-1;
connected=ones(64,1);
% this way we dont need to make a new one each time we have a 
xcoords=eLoc(chanMap,1);
ycoords=eLoc(chanMap,2);
kcoords=repmat([1:8]',1,8)';
kcoords=kcoords(:)';
save ChanMapBird.mat nChannels chanMap chanMap0ind connected xcoords ycoords kcoords AnatGroup
%% Bird,  Broken Shank
reboot;
load ../../../../SiProbe/Probe/AnatGroup.mat
nChannels=64;
connected=repmat([0,0,1,1,1,1,1,1]',1,8)';connected=connected(:)';%remove first shank
connected=logical(connected);
chanMap=[AnatGroup{:}]+1;
chanMap0ind=chanMap-1;
xcoords=eLoc(chanMap,1);
ycoords=eLoc(chanMap,2);
kcoords=repmat((1:8)',1,8)';
kcoords=kcoords(:)';
save ChanMapBird_12broken.mat nChannels chanMap chanMap0ind connected xcoords ycoords kcoords AnatGroup
%% Human STN
reboot;
nChannels=3;
chanMap=1:3;
chanMap0ind=chanMap-1;
connected=logical([1,1,1]);
% this way we dont need to make a new one each time we have a 
xcoords=[0 0 0];
ycoords=[10 5 0];
kcoords=[1,1,1];
save HumanSTN.mat nChannels chanMap chanMap0ind connected xcoords ycoords kcoords
%% Fan Wu,T1
reboot;
load S:\Vigi\Matlab\CorticalSpikes\Probe\FanWu\T1.mat
nChannels=64;
chanMap=1:64;
chanMap0ind=chanMap-1;
connected=true(1,64);
% this way we dont need to make a new one each time we have a 
xcoords=eLoc(:,1);
ycoords=eLoc(:,2);
kcoords=ones(1,64);
save T1.mat nChannels chanMap chanMap0ind connected xcoords ycoords kcoords
%% Fan Wu,T2
reboot;
load S:\Vigi\Matlab\CorticalSpikes\Probe\FanWu\T2.mat
nChannels=64;
chanMap=1:64;
chanMap0ind=chanMap-1;
connected=true(1,64);
% this way we dont need to make a new one each time we have a 
xcoords=eLoc(:,1);
ycoords=eLoc(:,2);
kcoords=ones(1,64);
save T2.mat nChannels chanMap chanMap0ind connected xcoords ycoords kcoords
%% Fan Wu,T3
reboot;
load S:\Vigi\Matlab\CorticalSpikes\Probe\FanWu\T3.mat
nChannels=64;
chanMap=1:64;
chanMap0ind=chanMap-1;
connected=true(1,64);
% this way we dont need to make a new one each time we have a 
xcoords=eLoc(:,1);
ycoords=eLoc(:,2);
kcoords=group;
save T3.mat nChannels chanMap chanMap0ind connected xcoords ycoords kcoords
%% Erez
reboot;
load S:\Vigi\Matlab\CorticalSpikes\Probe\Erez.mat
nChannels=64;
chanMap=1:64;
chanMap0ind=chanMap-1;
connected=true(1,64);
connected([20,42,58])=false;
% this way we dont need to make a new one each time we have a 
xcoords=eLoc(:,1);
ycoords=eLoc(:,2);
kcoords=ones(1,64);
save 387_2.mat nChannels chanMap chanMap0ind connected xcoords ycoords kcoords
%% Sotiris, 64H
reboot
load 64H_bottom.mat
nChannels=64;
chanMap=1:64;
chanMap0ind=chanMap-1;
connected=true(1,64);
xcoords=x;
ycoords=y;
kcoords=[ones(1,32),2*ones(1,32)];
AnatGroup{1}=0:31;
AnatGroup{2}=32:63;
clear x y
save 64H.mat 