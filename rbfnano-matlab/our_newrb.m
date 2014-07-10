function [net perf] = our_newrb(param)


end


function net = create_network(param)

  % Data
  p = param.inputs;
  t = param.targets;
  if iscell(p), p = cell2mat(p); end
  if iscell(t), t = cell2mat(t); end

  % Max Neurons
  Q = size(p,2);
  mn = param.maxNeurons;
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
  warn1 = warning('off','MATLAB:rankDeficientMatrix');
  warn2 = warning('off','MATLAB:nearlySingularMatrix');
  [w1,b1,w2,b2,tr] = designrb(p,t,param.goal,param.spread,mn,param.displayFreq);
  warning(warn1.state,warn1.identifier);
  warning(warn2.state,warn2.identifier);

  net.layers{1}.size = length(b1);
  net.b{1} = b1;
  net.iw{1,1} = w1;
  net.b{2} = b2;
  net.lw{2,1} = w2;
end

%======================================================
function [w1,b1,w2,b2,tr] = designrb(p,t,eg,sp,mn,df)

  [r,q] = size(p);
  [s2,q] = size(t);
  b = sqrt(-log(.5))/sp;

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
  tr = nntraining.newtr(mn,'perf');
  tr.perf(1) = mse(t-repmat(mean(t,2),1,q));
  tr.perf(2) = MSE;
  if isfinite(df)
    fprintf('NEWRB, neurons = 0, MSE = %g\n',tr.perf(1));
  end
  flag_stop=plotperfrb(tr,eg,'NEWRB',0);

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

    % PROGRESS
    tr.perf(k+1) = MSE;

    % DISPLAY
    if isfinite(df) & (~rem(k,df))
      fprintf('NEWRB, neurons = %g, MSE = %g\n',k,MSE);
      flag_stop=plotperfrb(tr,eg,'NEWRB',k);
    end

    % CHECK ERROR
    if (MSE < eg), break, end
    if (flag_stop), break, end

  end

  [S1,R] = size(w1);
  b1 = ones(S1,1)*b;

  % Finish
  if isempty(k), k = 1; end
  tr = nntraining.cliptr(tr,k);
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
