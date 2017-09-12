function [s,Wraw]=gather_mean_spikesV(rez,ops,DATA)
tic;
%THIS DOESNT WORK
%preload some stuff
Nfilt=ops.Nfilt;
Nrank   = ops.Nrank;
Nbatch_buff = rez.temp.Nbatch_buff;

%remove weird negatives
st3 = rez.st3;
st3(st3(:,3)<0, :) = [];
rez.st3pos = st3;%positive amplitudes. 
if ~isempty(ops.chanMap)
    if isstring(ops.chanMap)
        load(ops.chanMap);
        chanMapConn = chanMap(connected>1e-6);
    else
        chanMapConn = ops.chanMap;
    end
else
    chanMapConn = 1:ops.Nchan;
end
NchanTOT = ops.NchanTOT;

d = dir(ops.fbinary);
ops.sampsToRead = floor(d.bytes/NchanTOT/2);


NT          = 128*1024+ ops.ntbuff;
NTbuff      = NT + 4*ops.ntbuff;
Nbatch      = ceil(d.bytes/2/NchanTOT /(NT-ops.ntbuff));

% load data into patches, filter, compute covariance, write back to
% disk

fprintf('Time %3.0fs. Loading raw data... \n', toc);
fid = fopen(ops.fbinary, 'r');
ibatch = 0;
Nchan = ops.Nchan;

Nchans = ops.Nchan;
ts = [1:1:140]'-40;

clear stimes
for iNN = 1:Nfilt
    stimes{iNN} = rez.st3pos(rez.st3pos(:,2)==iNN,1);
end
% stimes = gtimes;
s=cell(Nfilt,1);
s_t=cell(Nfilt,1);
Wraw = zeros(numel(ts), Nchans, Nfilt);%time x channel x templates
for ibatch = 1:Nbatch    
    %load data
    if ibatch>Nbatch_buff
        offset = 2 * ops.Nchan*batchstart(ibatch-Nbatch_buff); % - ioffset;
        fseek(fid, offset, 'bof');
        dat = fread(fid, [NT ops.Nchan], '*int16');
    else
       dat = DATA(:,:,ibatch); 
    end
    dataRAW = gpuArray(dat);
    dataRAW = single(dataRAW);
    dataRAW = dataRAW / ops.scaleproc;
        
    
    if ibatch==1; ioffset = 0;
    else ioffset = ops.ntbuff;
    end
    %go through each spike
    for iNN = 1:numel(stimes)
        st = stimes{iNN} + ioffset - (NT-ops.ntbuff)*(ibatch-1) - 20;%rset to check indexing
        rm=(st<40)|(st>NT-2*ops.ntbuff);%take out any below or above
        ind2take=find(~rm);
        ii=sort(randperm(length(ind2take),min(length(ind2take),100)));%only take a subset
        ind2take=ind2take(ii);
        st=st(ind2take);
%         st(st>NT-ops.ntbuff) = [];        %take out any above

        
        if ~isempty(st)
            inds = repmat(st', numel(ts), 1) + repmat(ts, 1, numel(st));
            spikeWaves=reshape(dataRAW(inds, :), numel(ts), numel(st), Nchans);
            newT=stimes{iNN}(ind2take)';
            newW=gather(spikeWaves);
            s_t{iNN}=[s_t{iNN},newT];
            s{iNN}=[s{iNN},newW];
            spikeSet=squeeze(sum(spikeWaves,2));
            Wraw(:,:,iNN) = Wraw(:,:,iNN) + ...
                gather(spikeSet);
        end
    end
    if mod(ibatch,10)==0
        fprintf('%i /%i, ',ibatch,Nbatch)
    end
end

for iNN = 1:numel(stimes)
	Wraw(:,:,iNN) = Wraw(:,:,iNN)/numel(stimes{iNN});
	s{iNN}=s{iNN}*.195*ops.scaleproc;%convert to uV
end
fprintf('\nTime %3.2f. Mean waveforms computed... \n', toc);
Wraw=Wraw*.195*ops.scaleproc;%convert to uV
s=[s_t,s];