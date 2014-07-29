% The code for which PSO runs for each subdivision

% The pseudo code will look as follows:
% Create the subdivision of data.
% Pass this data to PSO func.
% Then the PSO will run

function yb=brute_pso(N,iterations,irange,jrange)
% Create a for loop

warning('off','all');
warning;
dataset = load_np_data();
good_data = dataset.good_data;
good_y = dataset.good_y;
[C R]=size(good_data)

% Now you have to divide the good_data into training, validation and test
% data
% i corresponds to training data size
% j corresponds to validation data size
pso_mat=[];
for i=irange
    for j=jrange
        if((i+j)>30 && (i+j)<(C-1))
        for k=1:10

           index_mat=randperm(C);
           train_data(:,:,k)=good_data(index_mat(1:i),:);
           train_y(:,:,k)=good_y(index_mat(1:i),:);
           disp([i j])
           val_data(:,:,k)=good_data(index_mat(i+1:i+1+j),:)
           val_y(:,:,k)=good_y(index_mat(i+1:i+1+j),:);
        end
        % Now run PSO
        var_i=(i-10)/5
        var_j=(j-10)/5
        pso_mat((i-10)/5,(j-10)/5,:)=pso_eng(N,iterations,[0.1 3 5 (i-5)],train_data,train_y,val_data,val_y);
        % Clear variables
        train_data=[];
        train_y=[];
        val_data=[];
        val_y=[];
        end
        if((i+j)<30 || (i+j)>80)
            var_i=(i-10)/5;
            var_j=(j-10)/5;
            pso_mat((i-10)/5,(j-10)/5,:)=[0 0 0];
        end
    end
end
yb=pso_mat;
end

function y = pso_eng(N,iterations,range,train_data,train_y,val_data,val_y)
% Create a population of agents having random positions. Positions will be
% s and Q
format long;
pop=[];
fitness=[];
for i=1:N
    pop=[pop;(rand*(range(2)-range(1))+range(1)) round(rand*(range(4)-range(3))+range(3))];
    fitness=[fitness;fitf(pop(i,:),train_data,train_y,val_data,val_y)];


end
% Population assigned random positions

% Create Gbest and Pbest .
pbest=pop;
[C I]=min(fitness);
gbest=pop(I,:);
% Gbest and Pbest done
fitg=fitness;
% Now start the iterations
velocity=zeros(N,2);
for iter=1:iterations
    iter
    % Change the velocity
    velocity=velocity+2.*rand(N,2).*(pbest-pop)+2.*rand(N,2).*([ones(N,1).*gbest(1,1) ones(N,1).*gbest(1,2)]-pop);
    % Now change the position
    pop1=pop+velocity;
    % Check whether the positions are inside the range
    for k=1:N
        if (pop1(k,1)<range(1,1)||pop1(k,1)>range(1,2))
            % then randomly initialise again
            pop1(k,1)=rand*(range(2)-range(1))+range(1);
        end
        if (pop1(k,2)<range(1,3)||pop1(k,2)>range(1,4))
            % then randomly initialise again
            pop1(k,2)=round(rand*(range(4)-range(3))+range(3));
        end
    end
    pop1=[pop1(:,1) round(pop1(:,2))];
    % Now check fitness
    for jm=1:N
        fitness1(jm,1)=fitf(pop1(jm,:),train_data,train_y,val_data,val_y);
        if (fitness1(jm,1)<fitness(jm,1))
            pbest(jm,:)=pop1(jm,:);
            fitg(jm,1)=fitness1(jm,1);
        end
    end
    % Updated the Pbest. Now its Gbest's turn.
    [C I]=min(fitg);
    gbest=pbest(I,:);
end

y=[gbest fitg(I,1)];

end


function y=fitf(pop,train_data,train_y,val_data,val_y)

s=pop(1,1);
Q=pop(1,2);
[r c depth]=size(train_data);




 for g=1:depth
         [w1f,bf,w2f,b2f] = trainrb(train_data(:,:,g)',train_y(:,:,g)',0.0,s,Q);

         ym(1,g) = testrb(w1f,bf,w2f,b2f,val_data(:,:,g)',val_y(:,:,g)');


 end
 y=mean(ym)+var(ym);
 end

 function [w1,w2] = trainrb1(p,t,tm,b,mn)
     P = tm(p,p);
     PP = sum(P.*P)';
     d = t';
     dd = sum(d.*d)

    % CALCULATE "ERRORS" ASSOCIATED WITH VECTORS
    e = ((P' * d)' .^ 2) ./ (dd * PP');

    [e used left] = pickLargeColumn(e,[],1:length(p));
    w1 = p(used);
    a1 = P(w1,p);
    w2 = t/a1;
    a2 = w2*a1;
    MSE = mse(t-a2);
    for k = 2:mn

    end
 end
 function [w1,b,w2,b2] = trainrb(p,t,eg,sp,mn)

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
 %  b1 = ones(S1,1)*b;

   % Finish
   if isempty(k), k = 1; end

end

function tguess = runrb(w1,b,w2,b2v,p);
     a1 = transfer(dist(w1,p)*b);
     a2 = w2*a1 + b2v;
end

 function err = testrb(w1,b,w2,b2v,p,t)

     err = mse(t-runrb(w1,b,w2,b2v,p));

 end
 %======================================================
 function phi = transfer(d,s)
     adj = sqrt(log(2))/s;
     phi = exp(adj.*d.^2);
 end

 function tm = transfer_matrix(inputs)
     tm = transfer(dist(inputs,inputs'));
 end

 function i = findLargeColumn(m)
   replace = find(isnan(m));
   m(replace) = zeros(size(replace));
   m = sum(m .^ 2,1);
   i = find(m == max(m));
   i = i(1);
 end

 function  [e used left] = pickLargeColumn(e,used,left)
   replace = find(isnan(e));
   e(replace) = zeros(size(replace));
   m = sum(e .^ 2,1);
   i = find(m == max(m));
   i = i(1);
   e(i,:) = [];
   e(:,i) = [];
   used = [used ;i];
   left(i) = [];

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
