function amp_mV=getmV(rez)
%%
Fdat=rez.ops.fbinary;%get file
Ffil=strrep(Fdat,'.dat','.fil');
nChan=rez.ops.NchanTOT;%# of channnels
timeStamps=rez.st3(:,1);%spike times
clusters=rez.st3(:,2);%cluster IDs
amp_mV=zeros(size(timeStamps));
c=unique(clusters');
[a,inds]=deal(cell(length(c),1));

%do a memory map. 
if exist(Ffil,'file')
    disp('Using highpass filtered file')
    FileInf = dir(Ffil);
    nSampsInDat = (FileInf.bytes/nChan/2);
    rawData = memmapfile(Ffil, 'Format', {'int16', [nChan, nSampsInDat], 'x'});
    parfor ci=1:length(c)
        Template = rez.Wraw(:,:,c(ci));
        [~,maxChan] = max(mean(abs(Template),2));
        inds{ci}=clusters==c(ci);
        a{ci}= double(rawData.Data.x(maxChan,timeStamps(inds{ci})))*.195;
    end
else
    disp('No filtered file, amplitude will be range instead')
    FileInf = dir(Fdat);
    nSampsInDat = (FileInf.bytes/nChan/2);
    rawData = memmapfile(Fdat, 'Format', {'int16', [nChan, nSampsInDat], 'x'});
    lenSpike=size(rez.dWU,1);%length of a spike
    indR=(1:lenSpike)-round(lenSpike/3);
    parfor ci=1:length(c)
        Template = rez.Wraw(:,:,c(ci));
        [~,maxChan] = max(mean(abs(Template),2));
        inds{ci}=find(clusters==c(ci));
        for s=1:length(inds{ci})% 
            ind_spike=timeStamps(inds{ci}(s))+indR;
            ind_spike(ind_spike<1)=[];
            ind_spike(ind_spike>nSampsInDat)=[];
            a{ci}(s)=range(double(rawData.Data.x(maxChan,ind_spike))*.195);
        end
    end
end
for ci=1:length(c)
    amp_mV(inds{ci})=a{ci};
end
