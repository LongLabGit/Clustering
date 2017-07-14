%% Bird
reboot;
load ../../../../SiProbe/Probe/AnatGroup.mat
chanMap=1:64;
chanMap0ind=chanMap-1;
connected=ones(64,1);
% connected([28 17 19 21 27 20 24 25]+1)=0;

incl=logical(connected);
maxDist=21; %??
shankInd=ones(64,1);
xcoords=eLoc(:,1);
ycoords=eLoc(:,2);
save ChanMapBird.mat
%% Human, cut and organized per channel
% reboot;
load /media/S/Vigi/Matlab/Neurogrid/Probe/AnatGroup.mat
nChannels=120;
chanMap=[AnatGroup{:}]+1;
chanMap0ind=chanMap-1;
connected=ones(nChannels,1);
shankInd=ones(nChannels,1);
incl=true([120,1]);
maxDist=21; %??
for g=1:length(AnatGroup)
    chns=AnatGroup{g}+1;
    locs=eLoc(chns,:);
    for c=1:length(chns)
        l=eLoc(chns(c),:);
        xii=floor(l(1)/1.89)*3;
        right=any(mod(l(1),1.89));
        yii=floor(l(2)/1.89)*3;
        up=any(mod(l(2),1.89));
%         xcoords(chns(c))=xii+right;
%         ycoords(chns(c))=yii+up;
        xcoords(chanMap==chns(c))=xii+right;
        ycoords(chanMap==chns(c))=yii+up;
    end
end
ycoords=ycoords';
xcoords=xcoords';
clearvars c chns g l locs right up xii yii sp22ind
save ChanMap120.mat nChannels chanMap chanMap0ind connected shankInd incl maxDist xcoords ycoords AnatGroup
%% Human, original
reboot;
load /media/S/Vigi/Matlab/Neurogrid/Probe/AnatGroup.mat
nChannels=128;
chanMap=[AnatGroup{:}]+1;
chanMap0ind=chanMap-1;
connected=ones(nChannels,1);
shankInd=ones(nChannels,1);
connected(121:end)=0;
shankInd(121:end)=0;
incl=[true([120,1]);false([8,1])];
maxDist=21; %??
for g=1:length(AnatGroup)
    chns=AnatGroup{g}+1;
    locs=eLoc(chns,:);
    for c=1:length(chns)
        l=eLoc(chns(c),:);
        xii=floor(l(1)/1.89)*3;
        right=any(mod(l(1),1.89));
        yii=floor(l(2)/1.89)*3;
        up=any(mod(l(2),1.89));
        xcoords(chns(c))=xii+right;
        ycoords(chns(c))=yii+up;
    end
end
ycoords=ycoords';
xcoords=xcoords';
clearvars c chns g l locs right up xii yii sp22ind
save ChanMap128.mat nChannels chanMap chanMap0ind connected shankInd incl maxDist xcoords ycoords AnatGroup
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
