function [duplex_r,E_r,duplex_full,E_full] = CCM_NNfull(dna_ratio,size_ratio,NN,NP,d_array,rho_AA,rho_BB,sigma)
% Input
% dna_ratio: DNA ratio array
% dna_increase: DNA linker length increase array
% NN_A_A: nearest neighbor A of type A
% NN_A_B: nearest neighbor A of type B
% NN_B_A: nearest neighbor B of type A
% NN_B_B: nearest neighbor B of type B
% NP_A: number of particle A in lattice
% NP_B: number of particle B in lattice

% Output
% duplex: duplex formation percentage
% size_ratio: DNA-NP size ratio
% E: energy

NN_full{1} = NN;
NN_full{2} = fliplr(NN);
NP_full = [NP; fliplr(NP)];
dna_ratio_full = [dna_ratio; 1/dna_ratio];
size_ratio_full = [size_ratio; 1/size_ratio];
rho = [rho_AA rho_BB];
rho_array = [rho; fliplr(rho)];
% Preallocation
duplex_full = zeros(1,length(NN_full(:,1)));
E_full = zeros(1,length(NN_full(:,1)));
for i = 1:length(NN_full)
    NN_array = NN_full{i};
    NP_array = NP_full(i,:);
    dna_ratio = dna_ratio_full(i);
    size_ratio = size_ratio_full(i);
    rho_input = rho_array(i,:);
%     [duplex,E] = CCM_NN(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma);
    [duplex,E] = CCM_NN(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_input(1),rho_input(2),sigma);
    duplex_full(i) = duplex;
    E_full(i) = E;   
end
duplex_r = max(duplex_full);
E_r = min(E_full);
end