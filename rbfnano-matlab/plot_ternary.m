%% Setup


data = load_np_data();
rbf = rbf_model();
gd = data.good_data;

tr_size = 30;
val_size = 30;
%% Select Data
p = randperm(length(gd));

tr_p = p(1:tr_size);
tr_y = data.good_y(tr_p,:);

% train model
s = 0.8;
Q = 15;

tm = rbf.phi(dist(gd,gd'),s);
[w1 w2] = rbf.train(tr_p,tr_y,tm,Q);

% Check error on validation set

val_p = p(tr_size+1:tr_size+1+val_size);
val_y = data.good_y(val_p,:);

rbf.test(w1,w2,tm,val_p,val_y)

%% Generate all points
A = [];
Rs = 0.1:0.1:1;
Rl = 0.1:0.1:1
Rn = 1:0.25:4;
[X Y Z] = meshgrid(Rs,Rl,Rn);

P = [X(:) Y(:) Z(:)];

tm_sweep = rbf.phi(rbf.edm(gd,P),s);

A = rbf.run(w1,w2,tm_sweep,1:length(P))';

%% Holdout points

ho_p = p(tr_size+1+val_size:end);
ho_y = data.good_y(ho_p,:);
%% Plot results
figure
addpath('./ternary_plot')

%% Plot sweep
[h,hg,htick]=terplot;
%-- Plot the data ...
hter=ternaryc(A(:,1),A(:,2),A(:,3));
%-- ... and modify the symbol:
set(hter,'marker','o','markerfacecolor','none','markersize',4)
hlabels=terlabel('AlB2','Cr3Si','CsCl');

%% guess for holdouts
H = rbf.run(w1,w2,tm,ho_p)';
err = mse(ho_y'-w2*tm(w1,ho_p))


%% Guess for clusters

tm_cluster = rbf.phi(rbf.edm(gd,data.cluster_data),s);
C = rbf.run(w1,w2,tm_cluster,1:length(data.cluster_data))';

%% Plot data
figure;
[h,hg,htick]=terplot;
%-- Plot the data ...
for i = 1:length(H)
hter=ternaryc(H(i,1),H(i,2),H(i,3));
set(hter,'marker','o','markerfacecolor',ho_y(i,:),'markersize',4)
end

hter=ternaryc(C(:,1),C(:,2),C(:,3));
set(hter,'marker','s','markerfacecolor','none','markersize',4)


hlabels=terlabel('AlB2','Cr3Si','CsCl')
