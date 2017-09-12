%reboot;
f='G:\Dropbox\Dina Project\ClusterScores.xlsx';
thresh=.2;
num=xlsread(f)';
frate=num(3,:);
isiv_2=num(4,:);
isiv_05=num(5,:);
d=num(7,:);
lr=num(8,:);
v_i=num(10,:);
v_d=num(11,:);
dina_score=num(14,:);
precision_nb=num(16,:);

%%
figure(1);clf;
subplot(1,2,1);cla;hold on;
good=isiv_05(v_i<=thresh);
bad=isiv_05(v_i>thresh);
histogram(good,0:.1:1);
histogram(bad,0:.1:1);
legend('good','bad')
title(['Isi Fraction, n keep =' num2str(length(good))])
subplot(1,2,2);cla;hold on;
good=d(v_d<=thresh);
bad=d(v_d>thresh);
histogram(good,0:3:90);
histogram(bad,0:3:90);
legend('good','bad')
title(['PCA Distance, n keep =' num2str(length(good))])
%%
perfect_inds=find(dina_score==3);
bad_inds=find(dina_score==1);
questionable_inds=find(dina_score==2);
figure(1);clf; set(gcf,'Color','white');
subplot(3,2,1); histogram(isiv_05(perfect_inds),20); box off; title('isi violations'); ylabel('good'); xlim([0,1]);
subplot(3,2,2); histogram(d(perfect_inds),20); box off; title('isolation distance'); xlim([0,90]);
subplot(3,2,3); histogram(isiv_05(questionable_inds),20); box off; ylabel('questionable'); xlim([0,1]);
subplot(3,2,4); histogram(d(questionable_inds),20); box off; xlim([0,90]);
subplot(3,2,5); histogram(isiv_05(bad_inds),20); box off; ylabel('bad'); xlim([0,1]);
subplot(3,2,6); histogram(d(bad_inds),20); box off; xlim([0,90]);
[length(perfect_inds),length(questionable_inds),length(bad_inds)] %25    42     6
%%
% precision versus scores:
figure; set(gcf,'Color','white');
subplot(3,1,1); plot(isiv_05,precision_nb,'o'); box off; title('isi violations'); ylabel('precision')
subplot(3,1,2); plot(d,precision_nb,'o'); box off; title('isolation distance'); ylabel('precision')
subplot(3,1,3); plot(lr,precision_nb,'o'); box off; title('L-Ratio'); ylabel('precision')


[R,P]=corrcoef(isiv_05,precision_nb)% R=0.4; P=0.14;
[R,P]=corrcoef(d,precision_nb)% R=-0.6; P=0.027;
[R,P]=corrcoef(lr,precision_nb)% R=-0.6; P=0.027;

%%
figure; set(gcf,'Color','white');
plot(frate,precision_nb,'o'); box off;
xlabel('Firing Rate');
ylabel('Precision (no bursts)');
[R,P]=corrcoef(frate,precision_nb)% R=0.11; P=0.34;















