% Thi Vo
% Columbia University
% Pressure Dependent Phase Transition

clear all; close all; clc;

% Defining sigma
sigma = 5;

% Defining DNA ratio
dna_ratio = 1;%linspace(0.2,3,100);

% Defining size_ratio
size_ratio = 1;%linspace(0.2,1,100);

% Defining grafting density
rho_AA = 1;
rho_BB = 1-1E-8;

% Compression
comp = linspace(0.2,1.2,250);
comp_m = 1;

% Calculations
% BCC
% Nearest neighbor array
NN_array = [0 8 8 0; 6 0 0 6; 12 0 0 12];
% Number of particle in lattice array
NP_array = [1 1];
% Experimental stoichiometry
NP_exp = NP_array;
% Nearest neighbor distance array
d_array = [1; 1.15; 1.633];
% d_array = 1;

% Preallocation
duplex1 = zeros(length(dna_ratio),length(size_ratio));
for i = 1:length(comp)
    comp_temp = comp(i);
    [~,E] = CCM_NNmain(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma,NP_exp,comp_temp,comp_m);
    duplex1(i) = -E;
end

% FCC
% Nearest neighbor array
NN_array = [8 4 12 0; 6 0 0 6; 16 8 24 0];
% Number of particle in lattice array
NP_array = [3 1];
% Experimental stoichiometry
NP_exp = NP_array;
% Nearest neighbor distance array
d_array = [1; 1.414; 1.731];
% d_array = 1;

% Preallocation
duplex2 = zeros(length(dna_ratio),length(size_ratio));
for i = 1:length(comp)
    comp_temp = comp(i);
    [~,E] = CCM_NNmain(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma,NP_exp,comp_temp,comp_m);
    duplex2(i) = -E;
end

% SC
% Nearest neighbor array
NN_array = [0 6 6 0; 12 0 0 12; 0 6 6 0];
% Number of particle in lattice array
NP_array = [1 1];
% Experimental stoichiometry
NP_exp = NP_array;
% Nearest neighbor distance array
d_array = [1; 1.414; 1.732];
% d_array = 1;

% Preallocation
duplex3 = zeros(length(dna_ratio),length(size_ratio));
for i = 1:length(comp)
    comp_temp = comp(i);
    [~,E] = CCM_NNmain(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma,NP_exp,comp_temp,comp_m);
    duplex3(i) = -E;
end

% CuAu
% Nearest neighbor array
NN_array = [4 8 8 4; 6 0 0 6; 8 16 16 8];
% Number of particle in lattice array
NP_array = [1 1];
% Experimental stoichiometry
NP_exp = NP_array;
% Nearest neighbor distance array
d_array = [1; 1.414; 1.710];
% d_array = 1;

% Preallocation
duplex4 = zeros(length(dna_ratio),length(size_ratio));
for i = 1:length(comp)
    comp_temp = comp(i);
    [~,E] = CCM_NNmain(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma,NP_exp,comp_temp,comp_m);
    duplex4(i) = -E;
end

lw = 4;
figure(1)
plot(comp,duplex1,'r','LineWidth',lw)
hold on;
plot(comp,duplex2,'b','LineWidth',lw)
plot(comp,duplex3,'g','LineWidth',lw)
plot(comp,duplex4,'m','LineWidth',lw)
legend('BCC','FCC','SC',1)