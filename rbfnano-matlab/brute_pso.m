% The code for which PSO runs for each subdivision

% The pseudo code will look as follows:
% Create the subdivision of data.
% Pass this data to PSO func.
% Then the PSO will run

function yb=brute_pso(N,iterations)
% Create a for loop

warning('off','all');
warning;

%% Initialize variables.
filename = 'nanoparticle_dta.csv';
delimiter = ',';
startRow = 2;

%% Format string for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
rarb1 = dataArray{:, 1};
fafb1 = dataArray{:, 2};
nbna1 = dataArray{:, 3};
Structure = dataArray{:, 4};
data = [rarb1,fafb1,nbna1];
%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
%% Split into train/test/validate data

% sort data by structure name
[str, str_ind] = sort(Structure);
sort_data = data(str_ind,:);

% remove all the clusters (their names have lengths longer than 5)
cluster_ind = find(cellfun('length',str)>5);

% extract cluster data for later
cluster_data = sort_data(cluster_ind,:);
cluster_names = str(cluster_ind);

% remove cluster elements from array (THIS IS PAINFULLY STATEFUL)
sort_data(cluster_ind,:) = [];
str(cluster_ind,:) = [];

% name2vec = @(x) arrayfun(@(i) strcmp(i,x),{'"AlB2"', '"Cr3Si"', '"CsCl"'});
name2vec = @(x) arrayfun(@(i) strcmp(i,x),{'AlB2', 'Cr3Si', 'CsCl'});

% rename variables
good_data = sort_data;
good_str = str;
good_y = cell2mat(arrayfun(@(v) double(name2vec(v)),str,'UniformOutput',false));
[C R]=size(good_data)
% Now you have to divide the good_data into training, validation and test
% data
% i corresponds to training data
% j corresponds to validation data
pso_mat=[];
for i=30
    for j=30
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
            var_i=(i-10)/5
            var_j=(j-10)/5
            pso_mat((i-10)/5,(j-10)/5,:)=[0 0 0];
        end
    end
end
yb=pso_mat;
end

function y=pso_eng(N,iterations,range,train_data,train_y,val_data,val_y)
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

% for g=1:depth
%         net = newrb(train_data(:,:,g)',train_y(:,:,g)',0.0,s,Q);
%         Y = sim(net,val_data(:,:,g)');
%         ym(1,g)=mse(Y-val_y(:,:,g)');
% end
% y=mean(ym)+var(ym);
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

 function [w1,b,w2,b2] = trainrb(p,t,eg,sp,mn)
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
 %  b1 = ones(S1,1)*b;

   % Finish
   if isempty(k), k = 1; end

 end

 function err = testrb(w1,b,w2,b2,p,t)
 %p = val_data
 %t = val_y
   %b = sqrt(log(2))/sp;
   [r,q] = size(p);
     a1 = radbas(dist(w1,p)*b);
  %   [w2,b2] = solvelin2(a1,t);
     a2 = w2*a1 + b2*ones(1,q);
     err = mse(t-a2);

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
