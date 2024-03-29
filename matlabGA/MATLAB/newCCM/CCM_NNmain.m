% Thi Vo
% Columbia University
% Complementary Contact Model - Combined Function

function [duplex_f,E_f,test,dev,duplexf,Ef] = CCM_NNmain(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma)
% Initialize
L_AT = 200;

% Preallocation
E_f1 = zeros(2,1);
duplex_f1 = zeros(2,1);

% Main Code
L_BT = L_AT*dna_ratio;

[~,~,duplexf,Ef] = CCM_NN(size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma,L_AT,L_BT);
[dev,test] = CCM_deviation(size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,L_AT,L_BT);

for k = 1:length(Ef)
    E_f1(k) = Ef(k);
    duplex_f1(k) = duplexf(k);
end
duplex_f = min(duplex_f1);
E_f = max(E_f1);