function [auto_clusts,shank,rm]=findLocalClusters(rez,correct)
%This will suggest correct clusters on the idea 
if nargin<2
    correct=1;
end
% First find levels across shanks for each filter/cluster
ops=rez.ops;
load([ops.chanMap])

shank=zeros(1,ops.Nfilt);
distance=zeros(1,ops.Nfilt);
nspikes=zeros(1,ops.Nfilt);
for c=1:ops.Nfilt
    wa = squeeze(rez.U(:,c,:)) * squeeze(rez.W(:,c,:))';%reconstruct template
    amp=min(wa,[],2);%find the minimum amplitude over time
    spatialMask=zscore(abs(amp));%take the zscore of the first PC for this template
    [lvl,chan]=max(spatialMask);%find the channel 
    shank(c)=kcoords(chan);
    otherShanks=spatialMask(kcoords ~= shank(c));%get everyone else
    distance(c)=lvl-max(otherShanks);%whats the closest level in everyone else?
    nspikes(c)=sum(rez.st3(:,2)==c);
end
% Then throw out those who are within 2std
% auto_clusts=find(distance>2&nspikes>100);
auto_clusts=find(distance>2);
auto_clusts=intersect(unique(rez.st3(:,2)),auto_clusts);%some times the filter exists but no spikes do
auto_clusts=reshape(auto_clusts,1,length(auto_clusts));%make sure its a row vector
%% put corrections in here. only important for vigi
if correct==1
    %remove shanks based on prior 
    rm1=[];
    if ~isempty(strfind(ops.root,'4_27_16'))
        rm1=find(shank==8);%shank 8 was out of the brain
    elseif ~isempty(strfind(ops.root,'6_22_16'))
        rm1=find(shank==1);
    elseif ~isempty(strfind(ops.root,'6_29_16'))
        rm1=find(shank==1);
    end
    %remove clusters based on posterior
    rm2=[]; add=[];
    
    auto_clusts=setdiff(auto_clusts,[rm1,rm2]);
    auto_clusts=sort([auto_clusts,add]);
end
rm=setdiff(1:ops.Nfilt,auto_clusts);
% This is the graveyard of old manual corrections ignore it

%     if ~isempty(strfind(ops.root,'Session1_Denoised'))
%         if isequal(rez.ops.Th,[6,12,12])&&strcmp(rez.ops.initialize,'fromData')
%             add=[42 51 67 69 72];%fix it
%             rm2=[1,38,45,50,59,79,83,88,91,101,113,120,122,126,127,134,128,148,155,157,158,164,183,186,192];
%             %strange: 147 172 67
%         elseif isequal(rez.ops.Th,[2,5,5])&&strcmp(rez.ops.initialize,'fromData')
%             add=[96 101 150 177 177 190];%fix it
%             rm2=[8 28 53 57 78 106 115 120 126 127 131 151 152 172 175 185 191];
%         elseif isequal(rez.ops.Th,[2,5,5])&&strcmp(rez.ops.initialize,'no')
%             add=[12 26 50 74 97 102 115 124 130 135 154 162 183];%fix it
%             rm2=[44 48 73 78 103 11 117 131 136 158 176 189];
%         elseif isequal(rez.ops.Th,[6,12,12])&&strcmp(rez.ops.initialize,'no')
%             add=[4 21 50 89 68 74 88 92 127 154 177 178 183];%fix it
%             rm2=[32 38 73 98 101 115 124 126 128 129 151 153 161 169 185];
%         end
%     end    
%     if ~isempty(strfind(ops.root,'6_22_16/300um'))
%         add=16;%fix it
%         rm2=[3,49,51,53,66,70,78,84,86,87,92,94,95];
%     elseif ~isempty(strfind(ops.root,'6_29_16/250um'))
%         add=[94,57,46,45,39,8];%fix it
%         rm2=[95, 77 69 58 17 6];%fix it
%     elseif ~isempty(strfind(ops.root,'6_29_16/400um'))
%         rm2=[21,12,57];
%         add=[42,37,5];%fix it
%     elseif ~isempty(strfind(ops.root,'6_29_16/550um'))
%         rm2=[21,12];
%         add=[84,69,29];%fix it
%     elseif ~isempty(strfind(ops.fbinary,'Session1_ica3_cut'))%this is an
%     earlier version
%         rm2=[62,55,45,41,20,14,1];
%         add=[130,131,132];
%     elseif ~isempty(strfind(ops.fbinary,'Session1_ica3_cut'))
%         rm2=[80 77 30 22 18 184 177 162 132 113 185];
%         add=[2 89 92 73 58 120 117];