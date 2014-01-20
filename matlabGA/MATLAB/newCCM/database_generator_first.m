% Thi Vo
% Columbia University
% CCM  Database Creator

clear all; close all; clc;

cd('C:\matt\Documents\GitHub\DNA-NP-Prediction\MATLAB\newCCM')

% Reading Excel Database
[data,text] = xlsread('Crystal Database New.xlsx');

% Creating compound name array
% Preallocation
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

% % Cs6C60 Original
% % FCC
% % Nearest neighbor array
% NN_full = {[0 4 24 0]};
% % Number of particle in lattice array
% NP_full = {[6 1]};
% % Nearest neighbor distance array
% d_full = {[1]};
%
% compound_name = {'Cs6C60_ori'};

% Parameters
% Defining sigma ratio
sigma = 5;

% Setting up array
% Size Ratio
R_s_array = 0.4:0.1:1.0;
% Linker Ratio
R_l_array = 0.5:0.1:2.6;
% Grafting density
rho_AA = linspace(0.0,1,50);
rho_BB = linspace(0.0,1,50);

% Creating array of folder name
str1 = 'R_s = ';
str3 = ' R_l = ';
str5 = '.dat';
str6 = 'Cycle Number  ';
str7 = 'Subcycle Number  ';
% Preallocation
Et = zeros(length(rho_AA),length(rho_BB));

for i = 1:length(R_s_array)
    num = num2str(i);
    cnn = strcat(str6,num);
    disp(cnn)
    for j = 1:length(R_l_array)
        num = num2str(j);
        cnn = strcat(str7,num);
        disp(cnn)
        R_s = R_s_array(i);
        str2 = num2str(R_s);
        R_l = R_l_array(j);
        str4 = num2str(R_l);
        folder_name = strcat(str1,str2,str3,str4);
        mkdir(folder_name)
        cd(folder_name)
        for k = 1:length(compound_name)
            disp(k)
            for a = 1:length(rho_AA)
                for b = 1:length(rho_BB)
                    [~,E] = CCM_NNmain(R_l,R_s,NN_full{k},NP_full{k},d_full{k},rho_AA(a),rho_BB(b),sigma);
                    Et(a,b) = E;
                end
            end
            file_name = strcat(compound_name{k},str5);
            save(file_name,'Et','-ASCII')
        end
        cd ./..
    end
end



