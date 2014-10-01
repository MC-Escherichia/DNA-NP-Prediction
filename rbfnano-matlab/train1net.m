function net = train1net(X,Y,train_inds,val_inds,ss)

% Load model
rbf = rbf_model();
% calculate edm
edm = rbf.edm(X);

% search space

p = train_inds;
targets = Y(train_inds,:);

best_err = 10000;

val_error = @(w1,w2,tm) rbf.test(w1,w2,tm,val_inds, ...
                                 Y(val_inds,:));

for i = 1:length(ss)
    s= ss(i);

    % transfer matrix
    tm = rbf.phi(edm,s);


    [w1s,w2s] = rbf.trainAll(p,targets,tm,length(p));

    for j=1:length(p)
        err = val_error(w1s{j},w2s{j},tm);
        errors(i,j) = err;
        if err<best_err
            best_model = {w1s{j},w2s{j},s,j,p};
            best_err = err;
        end
    end
end

 net = {best_model,errors};

end
