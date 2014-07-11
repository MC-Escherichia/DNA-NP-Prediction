function net = our_newrbe(points,targets,spread)

net = create_network(points,targets,spread);

end

function net = create_network(p,t,sp)


  % Dimensions
  [R,Q] = size(p);
  [S,Q] = size(t);

  % Architecture
  net = network(1,2,[1;1],[1;0],[0 0;1 0],[0 1]);

  % Simulation
  net.inputs{1}.size = R;
  net.layers{1}.size = Q;
  net.inputWeights{1,1}.weightFcn = 'dist';
  net.layers{1}.netInputFcn = 'netprod';
  net.layers{1}.transferFcn = 'radbas';
  net.layers{2}.size = S;
  net.outputs{2}.exampleOutput = t;

  % Weight and Bias Values
  [w1,b1,w2,b2] = designrbe(p,t,param.spread);

  net.b{1} = b1;
  net.iw{1,1} = w1;
  net.b{2} = b2;
  net.lw{2,1} = w2;
end

%======================================================
function [w1,b1,w2,b2] = designrbe(p,t,spread)

  [r,q] = size(p);
  [s2,q] = size(t);
  w1 = p';
  b1 = ones(q,1)*sqrt(-log(.5))/spread;
  a1 = radbas(dist(w1,p).*(b1*ones(1,q)));
  x = t/[a1; ones(1,q)];
  w2 = x(:,1:q);
  b2 = x(:,q+1);

end
