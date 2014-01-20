function crystalData = loadCrystalData(path)

%% this function was mostly written by Thi, but this should make it easier to read; 
if(nargin<1)
 path = 'C:\matt\Documents\GitHub\DNA-NP-Prediction\MATLAB\newCCM\Crystal Database New.xlsx';
end

% Reading Excel Database
[data,text] = xlsread(path);

compound_name = cell(length(text)-3,1);
for i = 4:length(text)
    compound_name{i-3} = text{i,1};
end

% Creating lattice parameters array
% Preallocation
NN_full = cell(length(data),1);
NP_full = cell(length(data),1);
d_full = cell(length(data),1);
for i = 1:length(data)
    % Nearest Neighbor
    % First nearest neighbor
    A(1,:) = data(i,3:6);
    %     % Second nearest neighbor
    %     A(2,:) = data(i,8:11);
    %     % Third nearest neighbor
    %     A(3,:) = data(i,13:16);
    
    
    % Number of particle
    B = data(i,1:2);
    % Normalizing
    B = B/min(B);
    
    % Distance
    C = data(i,7);% data(i,12) data(i,17)];
    
    % Correcting input order
    if (B(2) ~= 1)
        B = fliplr(B);
        A = fliplr(A);
    end
    
    % Nearest neighbor array
    NN_full{i} = A;
    % Number of particle array
    NP_full{i} = B;
    % Distance array
    d_full{i} = C;
end


crystalData.names = compound_name;
crystalData.NNarr = NN_full;
crystalData.NParr = NP_full;
crystalData.dists = d_full; 