function rbf = rbf_model()

    runrb = @(w1,w2,tm,p) w2*tm(w1,p);
    phi = @(d,s) exp(-(d.^2).*sqrt(log(2))/s);
    transfer_mat = @(edm, s) phi(edm,s);

    rbf.train = @trainrb;
    rbf.trainAll = @trainall;
    rbf.run = runrb;
    rbf.test = @test_rb;
    rbf.edm = @(a) dist(a,a');
    rbf.phi = phi;
end

function err = test_rb_hard(w1,w2,tm,p,t)

    temp = w2*tm(w1,p);
    temp = temp';
    [vs is] = arrayfun(@(n) max(temp(n,:)),1:length(temp));
    err = sum(arrayfun(@(n,i) t(n,i) ~= 1, 1:length(temp),is));

end

function err = test_rb(w1,w2,tm,p,t)


    g = transpose(w2*tm(w1,p));
    gs = sum(g,2)*[1 1 1];
    ng = g./gs;
    err = sum(sum((t-ng).^2,2))

     a1 = tm(w1,p);
     w2 = t\a1';

   disp(err);

end

function err = test_rb_naive(w1,w2,tn,p,t)

    tmp = t - transpose(w2*tm(w1,p));

    err = sum(arrayfun(@(n) [0 0 0] ~= tmp(n,:),length(1:n)));

end

function y = output(r)
    answers = {[1 0 0] [0 1 0] [0 0 1]};
      [vs is] =  arrayfun(@(n) max(r(n,:)),1:length(r));
       y = cell2mat(answers(is)');
end

function  [used1 left] = pickLargeColumn(e,used,left)
   replace = find(isnan(e));
   e(replace) = zeros(size(replace));
   m = sum(e .^ 2,1);
   i = find(m == max(m));
   i = i(1);
   used1 = [used i];
   left(left==i) = [];

end

function [w1s,w2s] = trainall(p,t,tm,Q)
     P = tm(p,p);
     PP = sum(P.*P)';
     d = t';
     dd = sum(d.*d);


    % CALCULATE "ERRORS" ASSOCIATED WITH VECTORS
    e = ((P' * d')' .^ 2) ./  (dd * PP);


    [used left] = pickLargeColumn(e,[],1:length(p));
    wj = P(:,used(end));

    w1 = p(used);

     a1 = tm(w1,p)';
     w2 = d/a1';
     %    w2 = t'*1\a1; % What does this do?
     %    a2 = w2*a1;
     %    MSE = mse(t-a2);


     w1s{1}=w1;
     w2s{1}=w2;
    for k = 2:Q
        a = wj' * P/(wj'*wj);
        P = P - wj *a;
        PP = sum(P.*P)';

        e = ((P' * d')' .^ 2) ./  (dd * PP);

        [used left] = pickLargeColumn(e,used,left);
        wj = P(:,used(end));

        w1 = p(used);
        a1 = tm(w1,p)';
        w2 = d/a1';

        % a2 = w2*a1;
        %        MSE = mse(t-a2);
        w1s{k}=w1;
        w2s{k}=w2;
    end
 end


 function [w1,w2] = trainrb(p,t,tm,mn)

     P = tm(p,p);
     d = t';
     dd = sum(d.*d);

    for k = 1:mn
        PP = sum(P.*P)';

        e = ((P' * d')' .^ 2) ./  (dd * PP);

        [used left] = pickLargeColumn(e,used,left);
        wj = P(:,used(end));

        w1 = p(used);
        a1 = tm(w1,p);
        w2 = d/a1;

        if k == mn; break; end;

        a = wj' * P/(wj'*wj);
        P = P - wj *a;

    end
 end
