for i=unique(rez.st3(:,2))'
    inds=rez.st3(:,2)==i;doubled(i)=length(rez.st3(inds,1))-length(unique(rez.st3(inds,1)));
end
doubled(logical(doubled))
% d=find(doubled)
% inds=rez.st3(:,2)==47;
% m=mode(rez.st3(inds,1))
% sum(rez.st3(inds,1)==m)
% dd=rez.st3(inds,:);
% dd(find(dd(:,1)==m),:)