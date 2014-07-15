function message = makefastfns
    assignin('base','trainrb',@trainrb);
    assignin('base','testrb', @testrb);
    message = 'Done';
end
%======================================================
function [w1,b1,w2,b2] = trainrb(p,t,eg,sp,mn)
% eg=0
% sp = s
% mn = Q
% p = train_data
% t = train_y

  [r,q] = size(p);
  [s2,q] = size(t);
  b = sqrt(log(2))/sp;

  % RADIAL BASIS LAYER OUTPUTS
  P = radbas(dist(p',p)*b);
  PP = sum(P.*P)';
  d = t';
  dd = sum(d.*d)';

  % CALCULATE "ERRORS" ASSOCIATED WITH VECTORS
  e = ((P' * d)' .^ 2) ./ (dd * PP');

  % PICK VECTOR WITH MOST "ERROR"
  pick = findLargeColumn(e);
  used = [];
  left = 1:q;
  W = P(:,pick);
  P(:,pick) = []; PP(pick,:) = [];
  e(:,pick) = [];
  used = [used left(pick)];
  left(pick) = [];

  % CALCULATE ACTUAL ERROR
  w1 = p(:,used)';
  % ONCE YOU HAVE W1, you can find MSE by setting p to target
  a1 = radbas(dist(w1,p)*b);
  [w2,b2] = solvelin2(a1,t);
  a2 = w2*a1 + b2*ones(1,q);
  MSE = mse(t-a2);

  % Start

  iterations = min(mn,q);
  for k = 2:iterations

    % CALCULATE "ERRORS" ASSOCIATED WITH VECTORS
    wj = W(:,k-1);
    a = wj' * P / (wj'*wj);
    P = P - wj * a;
    PP = sum(P.*P)';
    e = ((P' * d)' .^ 2) ./ (dd * PP');

    % PICK VECTOR WITH MOST "ERROR"
    pick = findLargeColumn(e);
    W = [W, P(:,pick)];
    P(:,pick) = []; PP(pick,:) = [];
    e(:,pick) = [];
    used = [used left(pick)];
    left(pick) = [];

    % CALCULATE ACTUAL ERROR
    w1 = p(:,used)';
    a1 = radbas(dist(w1,p)*b);
    [w2,b2] = solvelin2(a1,t);
    a2 = w2*a1 + b2*ones(1,q);
    MSE = mse(t-a2);

    % CHECK ERROR
    if (MSE < eg), break, end

  end

  [S1,R] = size(w1);
  b1 = ones(S1,1)*b;

  % Finish
  if isempty(k), k = 1; end

end

function err = testrb(w1,b1,w2,b2,p,t)
%p = val_data
%t = val_y
    a1 = radbas(dist(w1,p)*b);
    [w2,b2] = solvelin2(a1,t);
    a2 = w2*a1 + b2*ones(1,q);
    mse = mse(t-a2);

end
%======================================================

function i = findLargeColumn(m)
  replace = find(isnan(m));
  m(replace) = zeros(size(replace));
  m = sum(m .^ 2,1);
  i = find(m == max(m));
  i = i(1);
end

%======================================================

function [w,b] = solvelin2(p,t)
  if nargout <= 1
    w= t/p;
  else
    [pr,pc] = size(p);
    x = t/[p; ones(1,pc)];
    w = x(:,1:pr);
    b = x(:,pr+1);
  end
end
