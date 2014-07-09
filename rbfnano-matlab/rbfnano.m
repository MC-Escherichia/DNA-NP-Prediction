%% Radial Basis Functions for Nanoparticles

master_mat=[];
%% Initialize variables.
filename = 'nanoparticle_dta.csv';
delimiter = ',';
startRow = 2;

%% Format string for each line of text:
%   column1: double (%f)
% column2: double (%f)
%   column3: double (%f)
% column4: text (%s)
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

test_frac = 0.20;
frac_int = ceil(test_frac*length(good_str));

do_full_optimization= 0;

if do_full_optimization 
    
    for b=1:1
   b
    r = randperm(length(good_str));
    clear train_data test_data test_y train_y
    test_data = good_data(r(1:frac_int),:);
    test_str = good_str(r(1:frac_int));
    test_y = good_y(r(1:frac_int),:);
    % test_y = cell2mat(arrayfun(name2vec,test_str,'UniformOutput',false));

    train_data = good_data(r(frac_int+1:end),:);
    train_str = good_str(r(frac_int+1:end),:);
    %train_y = cell2mat(arrayfun(name2vec,train_str,'UniformOutput',false));
    train_y = good_y(r(frac_int+1:end),:);


%% RBF

        for s=1:1:40
         for Q=1:1:12

             net = newrb(train_data',train_y',0.0,s/100,Q*5);
            [Y,Pf,Af,E,perf] = sim(net,test_data');
            data_mat(s,Q)=mse(Y-test_y');
         end
   
        end
    master_mat=[master_mat;data_mat];
    end

end

%% Found 0.25 and 40 by putzing
%%

some_mat=[];
j=1;
while (j<=40)
   some=[];
for i=j:40:800
  some=[some; master_mat(i,:)];
end
some_mat=[some_mat;mean(some)];
j=j+1;
end



%%

% Test the Network
outputs = net(inputs);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs)

% Recalculate Training, Validation and Test Performance
trainTargets = targets .* tr.trainMask{1};
valTargets = targets  .* tr.valMask{1};
testTargets = targets  .* tr.testMask{1};
trainPerformance = perform(net,trainTargets,outputs)
valPerformance = perform(net,valTargets,outputs)
testPerformance = perform(net,testTargets,outputs)

% View the Network
% view(net)

% Plots
% Uncomment these lines to enable various plots.
% figure, plotperform(tr)
% figure, plottrainstate(tr)
% figure, plotconfusion(targets,outputs)
% figure, plotroc(targets,outputs)
% figure, ploterrhist(errors)
