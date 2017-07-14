
%% Marius Version
%  create a channel map file
Nchannels = 32;
connected = ones(Nchannels, 1);
chanMap   = 1:Nchannels;
chanMap0ind = chanMap - 1;
xcoords   = ones(Nchannels,1);
ycoords   = [1:Nchannels]';
kcoords   = ones(Nchannels,1); % grouping of channels (i.e. tetrode groups)
save('C:\DATA\Spikes\20150601_chan32_4_900s\chanMap.mat', ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind')
Nchannels = 32;
connected = ones(Nchannels, 1);
chanMap   = 1:Nchannels;
chanMap0ind = chanMap - 1;

xcoords   = repmat([1 2 3 4]', 1, Nchannels/4);
xcoords   = xcoords(:);
ycoords   = repmat(1:Nchannels/4, 4, 1);
ycoords   = ycoords(:);
kcoords   = ones(Nchannels,1); % grouping of channels (i.e. tetrode groups)

save('C:\DATA\Spikes\Piroska\chanMap.mat', ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind')
%% Human, Neurogrid
reboot;
load S:/Vigi/Matlab/Neurogrid/Probe/AnatGroup.mat
nChannels=128;
chanMap=[[AnatGroup{:}]+1,121:128];
chanMap0ind=chanMap-1;
connected=ones(nChannels,1); connected(121:end)=0;
connected=logical(connected);
e2=floor(eLoc/1.89)*3+ceil(mod(eLoc,1.89));%
e2(121:128,1)=19;
e2(121:128,2)=30;
xcoords=e2(chanMap,1);
ycoords=e2(chanMap,2);
for i=1:120
    kcoords(i)=find(cellfun(@(x) any(x==chanMap(i)-1), AnatGroup, 'UniformOutput', 1));
end
kcoords(121:128)=33;
save ChanMap128.mat nChannels chanMap chanMap0ind connected xcoords ycoords kcoords AnatGroup
%% Human, cut and organized per channel
reboot;
load S:/Vigi/Matlab/Neurogrid/Probe/AnatGroup.mat
nChannels=120;
chanMap=[AnatGroup{:}]+1;
chanMap0ind=chanMap-1;
connected=ones(nChannels,1);
shankInd=ones(nChannels,1);
incl=true([120,1]);
e2=floor(eLoc/1.89)*3+ceil(mod(eLoc,1.89));%
xcoords=e2(chanMap,1);%sort it to anatomical/kilosort order
ycoords=e2(chanMap,2);
for i=1:120
    kcoords(i)=find(cellfun(@(x) any(x==chanMap(i)-1), AnatGroup, 'UniformOutput', 1));
end
% kcoords=ones(1,120);
save ChanMap120.mat nChannels chanMap chanMap0ind connected shankInd incl xcoords ycoords kcoords AnatGroup
%% Human remove some channels
reboot;
load S:/Vigi/Matlab/Neurogrid/Probe/AnatGroup.mat
nChannels=128;
chanMap=[[AnatGroup{:}]+1,121:128];
rm=[27,28,32,33,37,47,48,49,51,53,55,57,61,69,85,86,88,90,92,96,107,109,113,117,119];
chanMap0ind=chanMap-1;
connected=ones(nChannels,1); connected(121:end)=0;
connected(ismember(chanMap0ind,rm))=0;
connected=logical(connected);
e2=floor(eLoc/1.89)*3+ceil(mod(eLoc,1.89));%
e2(121:128,1)=19;
e2(121:128,2)=30;
xcoords=e2(chanMap,1);
ycoords=e2(chanMap,2);
for i=1:120
    kcoords(i)=find(cellfun(@(x) any(x==chanMap(i)-1), AnatGroup, 'UniformOutput', 1));
end
kcoords(121:128)=33;
save ChanMap_374.mat nChannels chanMap chanMap0ind connected xcoords ycoords kcoords AnatGroup

%%
reboot;
Nchannels = 22;
connected = true(Nchannels, 1);
chanMap   = 1:Nchannels;
chanMap0ind = chanMap - 1;
xcoords   = ones(Nchannels,1);
ycoords   = [1:Nchannels]';
kcoords   = ones(Nchannels,1); % grouping of channels (i.e. tetrode groups)

save Dion22.mat chanMap connected xcoords ycoords kcoords chanMap0ind
