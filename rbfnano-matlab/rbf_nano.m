%% Radial Basis Functions for Nanoparticles

master_mat=[];
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
%% Be consistent about flipping the data
flip_inds = find(rarb1 > 1);

for i=flip_inds
   data(i,:) = 1./data(i,:);
end


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
good_data = sort_data';
good_y = cell2mat(arrayfun(@(v) double(name2vec(v)),str,'UniformOutput',false))';

test_frac = 0.60;
frac_int = ceil(test_frac*length(good_data));

rbq = BufferedPriorityQueue(50);
rbeq = BufferedPriorityQueue(50);


res = {};
for b=1:10

    %% Sample Data
r = randperm(length(good_data));
clear train_data test_data test_y train_y

test_data = good_data(:,r(1:frac_int));
test_y = good_y(:,r(1:frac_int));


train_data = good_data(:,r(frac_int+1:end));
train_y = good_y(:,r(frac_int+1:end));


%% Loop over parameters
for Q=5:1:length(good_data)-frac_int-5
    s= 0.1;
    i = 1;
    step = 0.25;

    while s<= 4.0



        %% Train regular net
        rb_net = our_newrb(train_data,train_y,s,Q);
        Y = sim(rb_net,test_data);
        err = mse(Y-test_y);
        %rb_data_mat(s,Q)= err;

        rbq.insert(err,rb_net);
        res{i,Q,b} = [s err];
        if err < 0.04 && step > 0.05
                s = s - step;
                step = 0.05;
        elseif err < 0.10  && step > 0.1
            s = s-step;
            step = .1;
        elseif err > 0.15 && step < 0.25
            step = 0.25;
        end

        s = s + step;
        disp([err s step])
        i = i + 1;
        %% Train zero error net
      % e_errors = zeros(10,1);
      % for c =1:3
      %     r = randperm(length(train_data));
      %     train_exact = train_data(:,r(1:Q));
      %     train_exact_y = train_y(:,r(1:Q));
      %     rbe_net = our_newrbe(train_exact,train_exact_y,s/50);
      %     e_Y = sim(rbe_net,test_data);
      %     e_err = mse(e_Y-test_y);
      %     rbeq.insert(e_err,rbe_net);
      %     e_errors(c) = e_err;
      % end
      % rbe_data_mat(s,Q)= mean(e_errors);
    end

end


end


%%

save('results.mat','res');
save('nets.mat','rbq');
% do something with res
% do something with rbq



%%

% Test the Network
% outputs = net(inputs);
% errors = gsubtract(targets,outputs);
% performance = perform(net,targets,outputs)
%
% Recalculate Training, Validation and Test Performance
% trainTargets = targets .* tr.trainMask{1};
% valTargets = targets  .* tr.valMask{1};
% testTargets = targets  .* tr.testMask{1};
% trainPerformance = perform(net,trainTargets,outputs)
% valPerformance = perform(net,valTargets,outputs)
% testPerformance = perform(net,testTargets,outputs)
%
% View the Network
% view(net)

% Plots
% Uncomment these lines to enable various plots.
% figure, plotperform(tr)
% figure, plottrainstate(tr)
% figure, plotconfusion(targets,outputs)
% figure, plotroc(targets,outputs)
% figure, ploterrhist(errors)
