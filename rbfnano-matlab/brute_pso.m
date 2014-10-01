% The code for which PSO runs for each subdivision

% The pseudo code will look as follows:
% Create the subdivision of data.
% Pass this data to PSO func.
% Then the PSO will run
function yb=brute_pso ()
    yb = brute_pso1 (25,20,load_np_data());
    helpdlg('Brute_PSO is done running')
end

function yb=brute_pso1(N,iterations,data)

% Create a for loop

warning('off','all');

good_data = data.good_data;
good_y = data.good_y

[C R]=size(good_data)

% Now you have to divide the good_data into training, validation and test
% data
% i corresponds to training data size
% j corresponds to validation data size
edm = dist(good_data,good_data');


pso_mat = {};

irange = 15:10:C;
jrange = 15:10:C;
hasCr3Si = @(X,Y) sum(Y(:,3)); % Cr3Si is the third column

model = rbf_model();

parfor i=1:15
    I = i*5;
    for j=1:15
        J = j*5;
        disp([I,J]);
        if((I+J)>30 && (I+J)<(C-1))
        % Sample data 10 times, guranatee Cr3Si in training set.
        train_p = [];
        val_p = [];
        test_p = [];
        for k=1:10
            [p,vp,tp] = sampledata(good_data,good_y,I,J,hasCr3Si);
            train_p = [train_p,p'];
            val_p = [val_p,vp'];
            test_p = [test_p,tp'];
        end
        [res errs] = pso_eng(N,iterations,[0.1 3 5 I-5],train_p,val_p,test_p,good_y,edm,model);

        pso_mat{i,j} = {res,errs};
        % Clear variables
        train_p=[];
        train_y=[];
        else
            pso_mat{i,j}=NaN;
        end
    end

end

yb=pso_mat;
end

function [y errs] = pso_eng(N,iterations,range,train_p,val_p,test_p,Y,edm,model)
% Create a population of agents having random positions. Positions will be
% s and Q

pop=[];
fitness=[];
for i=1:N

    pop=[pop;(rand*(range(2)-range(1))+range(1)) round(rand*(range(4)-range(3))+range(3))];
    fitness=[fitness;fitf(pop(i,:),train_p,val_p,Y,edm,model)];



end
% Population assigned random positions

% Create Gbest and Pbest .Global best, and best population
pbest=pop;
[C I]=min(fitness);
gbest=pop(I,:);
% Gbest and Pbest done
fitg=fitness;
% Now start the iterations
velocity=zeros(N,2);
errs = [];
for iter=1:iterations
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
        fitness1(jm,1) = fitf(pop1(jm,:),train_p,val_p,Y,edm,model);
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

    [val_errs,test_errs ] = fitft(gbest,train_p,val_p,test_p,Y,edm,model)
    errs = [errs; val_errs,test_errs ];
y=[gbest fitg(I,1)];
y(2) = y(2)/length(train_p);
end

function y=fitf(pop,train_p,val_p,Y,edm,model)

s=pop(1,1);
Q=pop(1,2);
[r depth]=size(train_p);

tm = model.phi(edm,s);
ym = ones(depth,1);
for g=1:depth
         [w1,w2] = model.train(train_p(:,g),Y(train_p(:,g),:),tm,Q);
         ym(g) = model.test(w1,w2,tm,val_p(:,g),Y(val_p(:,g),:));
end
 y=mean(ym)+var(ym);
end


function [ym ymt] = fitft(pop,train_p,val_p,test_p,Y,edm,model)

s=pop(1,1);
Q=pop(1,2);
[r depth]=size(train_p);

 tm = model.phi(edm,s);

 ym = ones(depth,1);
 ymt = ones(depth,1);

for g=1:depth
         [w1,w2] = model.train(train_p(:,g),Y(train_p(:,g),:),tm,Q);
         ym(g) = model.test(w1,w2,tm,val_p(:,g),Y(val_p(:,g),:));
         ymt(g) = model.test(w1,w2,tm,test_p(:,g),Y(test_p(:,g),:));
end

end
