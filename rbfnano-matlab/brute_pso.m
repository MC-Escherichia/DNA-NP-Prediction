% The code for which PSO runs for each subdivision

% The pseudo code will look as follows:
% Create the subdivision of data.
% Pass this data to PSO func.
% Then the PSO will run
function yb=brute_pso ()
    yb = brute_pso1 (20,20);
end

function yb=brute_pso1(N,iterations)

% Create a for loop

warning('off','all');
warning;

load('data.mat');

% good_data = data.good_data;
% good_y = data.good_y

[C R]=size(good_data)

% Now you have to divide the good_data into training, validation and test
% data
% i corresponds to training data size
% j corresponds to validation data size
edm = dist(good_data,good_data');
pso_mat=[];
figure
hold on;
for i=irange
    for j=jrange
        if((i+j)>30 && (i+j)<(C-1))
        for k=1:10
            noCr3Si = 1;
            while noCr3Si ;
           index_mat=randperm(C);
           train_p(:,k) = index_mat(1:i);
           train_y(:,:,k) = good_y(train_p(:,k),:);

             noCr3Si= ~sum(train_y(:,3,k));
            end
           val_p(:,k) = index_mat(i+1:i+1+j);
           val_y(:,:,k) = good_y(val_p(:,k),:);


        end
        % Now run PSO
        var_i=(i-10)/5
        var_j=(j-10)/5
        [res g_prog] = pso_eng(N,iterations,[0.1 3 5 (i-5)],train_p, ...
                               train_y,val_p,val_y,edm,model);

        plot(g_prog);
        hold off;
        hold on;
        pso_mat((i-10)/5,(j-10)/5,:) = res;
        % Clear variables
        train_p=[];
        train_y=[];
        val_p=[];
        val_y=[];
        else
            pso_mat((i-10)/5,(j-10)/5,:)=[NaN NaN NaN];
        end
    end

end

yb=pso_mat;
end

function [y g_prog] = pso_eng(N,iterations,range,train_p,train_y,val_p,val_y,edm,model)
% Create a population of agents having random positions. Positions will be
% s and Q
format long;
pop=[];
fitness=[];
for i=1:N

    pop=[pop;(rand*(range(2)-range(1))+range(1)) round(rand*(range(4)-range(3))+range(3))];
    fitness=[fitness;fitf(pop(i,:),train_p,train_y,val_p,val_y,edm,model)];



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
        fitness1(jm,1)=fitf(pop1(jm,:),train_p,train_y,val_p,val_y,edm,model);
        if (fitness1(jm,1)<fitg(jm,1))
            pbest(jm,:)=pop1(jm,:);
            fitg(jm,1)=fitness1(jm,1);
        end
    end
    % Updated the Pbest. Now its Gbest's turn.
    [C I]=min(fitg);
    gbest=pbest(I,:);
    g_prog(iter) = fitg(I,1);
    pop=pop1;


end

y=[gbest fitg(I,1)];

end

function y=fitf(pop,train_p,train_y,val_p,val_y,edm,model)

s=pop(1,1);
Q=pop(1,2);
[r depth]=size(train_p);

tm = model.phi(edm,s);

for g=1:depth
         [w1,w2] = model.train(train_p(:,g),train_y(:,:,g),tm,Q);
         ym(g) = model.test(w1,w2,tm,val_p(:,g),val_y(:,:,g));



end
 y=mean(ym)+var(ym);
end
