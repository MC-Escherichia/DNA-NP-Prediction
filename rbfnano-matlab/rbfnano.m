%% Radial Basis Functions for Nanoparticles


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
cluster_ind = find(cellfun('length',str)>7);

% extract cluster data for later
cluster_data = sort_data(cluster_ind,:);
cluster_names = str(cluster_ind);

% remove cluster elements from array (THIS IS PAINFULLY STATEFUL)
sort_data(cluster_ind,:) = [];
str(cluster_ind,:) = [];

% rename variables 
good_data = sort_data;
good_str = str; 

test_frac = 0.80;
frac_int = ceil(0.80*length(good_str)); 
r = randperm(length(good_str));

name2vec = @(x) arrayfun(@(i) strcmp(i,x),{'"AlB2"', '"Cr3Si"', '"CsCl"'});

test_data = good_data(r(1:frac_int),:);
test_str = good_str(r(1:frac_int)); 
test_y = arrayfun(name2vec,test_str,'UniformOutput',false);
 
train_data = good_data(r(frac_int+1:end),:);
train_str = good_str(r(frac_int+1:end),:);
train_y = arrayfun(name2vec,test_str,'UniformOutput',false); 


% two hours later the data is ready
%% Define transfer function

phi = @(r,s) exp(-r^2/s^2); % Gaussian
% @(r) r^3    % cubic
% @(r) 1/(1+r) % cauchy

% SEE RADIAL BASIS FUNCTIONS Pg 185

%% RBF



