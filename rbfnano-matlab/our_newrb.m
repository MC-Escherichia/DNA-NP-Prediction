function [net perf] = our_newrb(points,targets,spread,maxNeurons)

net = create_network(points,targets,spread,maxNeurons);

end


function net = create_network(p,t,sp,mn)

  % Data
%p = param.inputs;
% t = param.targets;
  if iscell(p), p = cell2mat(p); end
  if iscell(t), t = cell2mat(t); end

  % Max Neurons
  Q = size(p,2);
  % mn = param.maxNeurons;
  if (mn > Q), mn = Q; end


  % Dimensions
  R = size(p,1);
  S2 = size(t,1);

  % Architecture
  net = network(1,2,[1;1],[1; 0],[0 0;1 0],[0 1]);

  % Simulation
  net.inputs{1}.size = R;
  net.layers{1}.size = 0;
  net.inputWeights{1,1}.weightFcn = 'dist';
  net.layers{1}.netInputFcn = 'netprod';
  net.layers{1}.transferFcn = 'radbas';
  net.layers{2}.size = S2;
  net.outputs{2}.exampleOutput = t;

  % Performance
  net.performFcn = 'mse';

  % Design Weights and Bias Values

  [w1,b1,w2,b2] = designrb(p,t,0.0,sp,mn);


  net.layers{1}.size = length(b1);
  net.b{1} = b1;
  net.iw{1,1} = w1;
  net.b{2} = b2;
  net.lw{2,1} = w2;
end

%======================================================
function [w1,b1,w2,b2] = designrb(p,t,eg,sp,mn)

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
