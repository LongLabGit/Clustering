function [rezF,shank2]=fixRez(rez,ac,shank)

[shank2,inds]=sort(shank);
ac2=ac(inds);

rm=setdiff(1:size(rez.simScore,1),ac2);
%first just take out a bunch of stuff
rezF=rez;
rezF.ops.Nfilt=length(ac2);
%Take out bad spikes
idkeep=ismember(rez.st3(:,2), ac2);
rezF.st3(~idkeep,:)=[];
rezF.cProj(~idkeep,:)=[];
rezF.cProjPC(~idkeep,:,:)=[];
%take only the ones we kept AND reorder them according to shanks
rezF.dWU=rezF.dWU(:,:,ac2);
rezF.Wraw=rezF.Wraw(:,:,ac2);
rezF.nspikes=rez.nspikes(ac2,:);
rezF.t2p=rezF.t2p(ac2,:);
rezF.iNeigh=rezF.iNeigh(:,ac2);
rezF.iNeighPC=rezF.iNeighPC(:,ac2);
rezF.simScore=rez.simScore(ac2,ac2);
rezF.W=rezF.W(:,ac2,:);
rezF.U=rezF.U(:,ac2,:);
rezF.mu=rezF.mu(ac2);
rezF.nbins=rezF.nbins(ac2);
rezF.ypos=rezF.ypos(ac2);


%renumber clusters
orig=rezF.st3(:,2);
for i=1:length(ac2)
    id=orig==ac2(i);
    rezF.st3(id,2)=i;
end
rezF.shank=shank2;
percSpikes=size(rezF.st3,1)/size(rez.st3,1);
fprintf('%i%% of spikes  & ',round(percSpikes*100))
percClusts=length(ac)/rez.ops.Nfilt;
fprintf('%i%% of clusters kept.\n',round(percClusts*100))