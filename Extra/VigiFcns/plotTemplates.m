% ch = channel number
close all;
xS=.2;
yS=15;
for k = 138
    figure(1);clf;hold on;
    wa = rez.dWU(:,:,k)';
    wa = 100 * wa;
    mW = wa;
    t = (1:size(mW,2))/ops.fs*1e3;
    amp=sum(abs(mW),2);
    if sum(amp(1:32))>sum(amp(33:64))
        chns=1:32;
    else
        chns=33:64;
    end
    for ch = chns
        xLoc = rez.xcoords(ch);
        yLoc = rez.ycoords(ch);
        plot((t+xLoc*xS),(mW(ch,:)+ yLoc*yS + 50));      
    end 
    title(num2str(k))
    good(k)=input('keep?');
end 

 for k = 1:length(good)
     if good == 0
         rez.dWU(:,:,k) = 0;
     end
 end