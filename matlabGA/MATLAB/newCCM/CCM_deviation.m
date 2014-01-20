% Thi Vo
% Columbia University
% Symmetry Deviation Check

function [dev,test] = CCM_deviation(size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,linker_AT,linker_BT)

% Calculating remaining grafting fractions
rho_AB = 1 - rho_AA;
rho_BA = 1 - rho_BB;

% Determining number of linkers
% Number of linker A on particle A
linker_AA = linker_AT*rho_AA;
% Number of linker B on particle A
linker_AB = linker_AT*rho_AB;
% Number of linker A on particle B
linker_BA = linker_BT*rho_BA;
% Number of linker B on particle B
linker_BB = linker_BT*rho_BB;

% Isolating nearest neighbors
NN_A_A = NN_array(1);
NN_A_B = NN_array(2);
NN_B_A = NN_array(3);
NN_B_B = NN_array(4);

% Isolating number of particles
NP_A = NP_array(1);
NP_B = NP_array(2);

% Nano-particle base parameters
% rad_NP_A: radius of nanoparticle A
% rad_NP_B: radius of nanoparticle B
% DNA_A: number of DNA base on linker A
% linker_AT: total number of linkers on particle A
rad_NP_A = 5.4;
rad_NP_B = 5.4;
DNA_A = 32;
dna_ideal = 0.255;
dna_increase = (((rad_NP_A + DNA_A*dna_ideal)/size_ratio) - rad_NP_B)/dna_ideal - DNA_A;

% Calculating overlap area
[overlap, area_total] = area_overlap(dna_increase,d_array);

% Obtaining overlap areas
area_AA = overlap(1);
area_AB = overlap(2);
area_BA = overlap(3);
area_BB = overlap(4);

% Obtaining total areas
area_total_A = area_total(1);
area_total_B = area_total(2);

% Calculating ratios
R_NN_A = NN_A_A/NN_A_B;
R_NN_B = NN_B_B/NN_B_A;

% Calculating deviations from symmetry
alpha = linker_AT*(1/(linker_AT*area_total_A))*(rho_AA*linker_AB + rho_AB*linker_AA);
beta = linker_AT*(1/(linker_AT*area_total_A))*(rho_AA*linker_BB + rho_AB*linker_BA);
gamma = linker_BT*(1/(linker_BT*area_total_B))*(rho_BB*linker_BA + rho_BA*linker_BB);
delta = linker_BT*(1/(linker_BT*area_total_B))*(rho_BB*linker_AA + rho_BA*linker_BA);
num1 = NP_A*alpha*(R_NN_A*area_AA)^2*(R_NN_B*area_BB + area_BA);
num2 = NP_B*beta*(area_AB*area_BA)*(R_NN_A*area_AA + area_AB);
dem1 = NP_B*gamma*(R_NN_B*area_BB)^2*(R_NN_A*area_AA + area_AB);
dem2 = NP_A*delta*(area_AB*area_BA)*(R_NN_B*area_BB + area_BA);

LHS = (NN_B_A*NP_A)/(NN_A_B*NP_B);
RHS = (num1 + num2)/(dem1 + dem2);

test = [LHS/RHS RHS/LHS];
test = min(test);

dev = (LHS-RHS)^2;
end
