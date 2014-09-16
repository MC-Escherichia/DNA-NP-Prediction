function net = train1net(X,Y,train_inds,val_inds)
% Create a for loop

warning('off','all');

% Load model
rbf = rbfmodel();
% calculate edm
edm = rbf.edm(X);

% search space
ss = 0.25:0.25:4
p = train_inds;
targets = T(train_inds);

best_err = 10000;


val_error = @(w1,w2,tm) rbf.test(w1{j},w2{j},tm,val_inds, ...
                                 Y(val_inds));

for i = 1:length(ss):
    s= ss(i);

    % transfer matrix
    tm = rbf.phi(edm,s);



    p = train_inds
    [w1s,w2s] = rbf.trainAll(p,targets,tm,length(p));

    for j=1:length(p)
        err = val_error(w1s{j},w2s{j},tm)
        errors(i,j) = err;
        if err<best_err
            best_model = [w1s{j},w2s{j},s,j,p];
        end
    end




end

figure
surf(ss,1:length(p),errors);
net = best_model;

end
