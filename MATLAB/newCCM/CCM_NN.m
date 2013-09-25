function [duplex_final,E_final,duplex_t,E_t] = CCM_NN(size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma,linker_AT,linker_BT)
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
% E: energy

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



% Defining grafting fraction
% rho_AB: grafting percentage of linker B on particle A
% rho_BB: grafting percentage of linker B on particle B
% rho_AA: grafting percentage of linker A on particle A
% rho_BA: grafting percentage of linker A on particle B
rho_AB = 1 - rho_AA;
rho_BA = 1 - rho_BB;

% Preallocation
% Number of linker A on particle A
linker_AA = linker_AT*rho_AA;
% Number of linker B on particle A
linker_AB = linker_AT*rho_AB;
% Number of linker A on particle B
linker_BA = linker_BT*rho_BA;
% Number of linker B on particle B
linker_BB = linker_BT*rho_BB;

% Preallocation
overlap = cell(1,length(d_array));
for i = 1:length(d_array)
    d = d_array(i);
 
    [overlap{i},area_total] = area_overlap(dna_increase,d);
end

% Calculating area restriction
% Caculating required area
% Initialization
area_req_A = 0;
area_req_B = 0;
for i = 1:length(d_array)
    prod = overlap{i}.*NN_array{i,:};
    area_req_A = area_req_A + sum(prod(1:2));
    area_req_B = area_req_B + sum(prod(3:4));
end
area_total_A = area_total(1);
area_total_B = area_total(2);
% Restriction: nearest neighbor particle A
if area_total_A < area_req_A
    restrict_area_A = area_total_A/area_req_A;
else
    restrict_area_A = 1;
end
% Restriction: nearest neighbor particle B
if area_total_B < area_req_B
    restrict_area_B = area_total_B/area_req_B;
else
    restrict_area_B = 1;
end

% Calculating duplex
% Preallocation
duplex = cell(1,length(d_array));
E = cell(1,length(d_array));
for i = 1:length(d_array)
    NNs = NN_array{i,1};
    NN_A_A = NNs(1);
    NN_A_B = NNs(2);
    NN_B_A = NNs(3);
    NN_B_B = NNs(4);
    NPs = NP_array{i,1};
    NP_A = NPs(1);
    NP_B = NPs(2);
    area_overlap_AA = overlap{i}(1);
    area_overlap_AB = overlap{i}(2);
    area_overlap_BA = overlap{i}(3);
    area_overlap_BB = overlap{i}(4);
    % Fraction: particle type A to nearest neighbor of type B
    fraction_A_B = NN_A_B*area_overlap_AB/area_req_A;
    % Fraction: particle type B to nearest neighbor of type A
    fraction_B_A = NN_B_A*area_overlap_BA/area_req_B;
    % Fraction: particle type A to nearest neighbor of type A
    fraction_A_A = NN_A_A*area_overlap_AA/area_req_A;
    % Fraction: particle type B to nearest neighbor of type B
    fraction_B_B = NN_B_B*area_overlap_BB/area_req_B;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Cross hybridization restrictions
    % Restriction: linker A (B) grafted onto A (B)
    if (linker_AA*fraction_A_B*NP_A) > (linker_BB*fraction_B_A*NP_B)
        restrict_linker_AAc = rho_AA*(linker_BB*fraction_B_A*NP_B)/(linker_AT*NP_A);
        restrict_linker_BBc = rho_BB;
        linker_AAc_r = linker_AA*fraction_A_B*NP_A - linker_BB*fraction_B_A*NP_B;
        linker_BBc_r = 0;
    else
        restrict_linker_AAc = rho_AA;
        restrict_linker_BBc = rho_BB*(linker_AA*fraction_A_B*NP_A)/(linker_BT*NP_B);
        linker_AAc_r = 0;
        linker_BBc_r = linker_BB*fraction_B_A*NP_B - linker_AA*fraction_A_B*NP_A;
    end
    % Restriction: linker A (B) grafted on B (A)
    if (linker_AB*fraction_A_B*NP_A) > (linker_BA*fraction_B_A*NP_B)
        restrict_linker_ABc = rho_AB*(linker_BA*fraction_B_A*NP_B)/(linker_AT*NP_A);
        restrict_linker_BAc = rho_BA;
        linker_ABc_r = linker_AB*fraction_A_B*NP_A - linker_BA*fraction_B_A*NP_B;
        linker_BAc_r = 0;
    else
        restrict_linker_ABc = rho_AB;
        restrict_linker_BAc = rho_BA*(linker_AB*fraction_A_B*NP_A)/(linker_BT*NP_B);
        linker_ABc_r = 0;
        linker_BAc_r = linker_BA*fraction_B_A*NP_B - linker_AB*fraction_A_B*NP_A;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Self hybridization restrictions
    % Restriction: linker A (B) grafted onto A
    if (linker_AA*fraction_A_A*NP_A) > (linker_AB*fraction_A_A*NP_A)
        restrict_linker_AAs = rho_AA*(linker_AB*fraction_A_A*NP_A)/(linker_AT*NP_A);
        restrict_linker_ABs = rho_AB;
        linker_AAs_r = linker_AA*fraction_A_A*NP_A - linker_AB*fraction_A_A*NP_A;
        linker_ABs_r = 0;
    else
        restrict_linker_AAs = rho_AA;
        restrict_linker_ABs = rho_AB*(linker_AA*fraction_A_A*NP_A)/(linker_AT*NP_A);
        linker_AAs_r = 0;
        linker_ABs_r = linker_AB*fraction_A_A*NP_A - linker_AA*fraction_A_A*NP_A;
    end
    % Restriction: linker B (A) grafted onto B
    if (linker_BB*fraction_B_B*NP_B) > (linker_BA*fraction_B_B*NP_B)
        restrict_linker_BBs = rho_BB*(linker_BA*fraction_B_B*NP_B)/(linker_BT*NP_B);
        restrict_linker_BAs = rho_BA;
        linker_BBs_r = linker_BB*fraction_B_B*NP_B - linker_BA*fraction_B_B*NP_B;
        linker_BAs_r = 0;
    else
        restrict_linker_BBs = rho_BB;
        restrict_linker_BAs = rho_BA*(linker_BB*fraction_B_B*NP_B)/(linker_BT*NP_B);
        linker_BBs_r = 0;
        linker_BAs_r = linker_BA*fraction_B_B*NP_B - linker_BB*fraction_B_B*NP_B;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Calculating repulsive pairs
    
    % Cross hybridization repulsion
    if (linker_AAc_r ~= 0) && (linker_BAc_r ~= 0)
        repulsive_Ac = min([linker_AAc_r linker_BAc_r]);
    else
        repulsive_Ac = 0;
    end
    
    if (linker_ABc_r ~= 0) && (linker_BBc_r ~= 0)
        repulsive_Bc = min([linker_ABc_r linker_BBc_r]);
    else
        repulsive_Bc = 0;
    end
    
    % Self hybridization repulsion
    if linker_AAs_r ~= 0
        repulsive_AAs = linker_AAs_r;
    else
        repulsive_AAs = 0;
    end
    
    if linker_ABs_r ~= 0
        repulsive_ABs = linker_ABs_r;
    else
        repulsive_ABs = 0;
    end
    
    if linker_BBs_r ~=0
        repulsive_BBs = linker_BBs_r;
    else
        repulsive_BBs = 0;
    end
    
    if linker_BAs_r ~=0
        repulsive_BAs = linker_BAs_r;
    else
        repulsive_BAs = 0;
    end
    
    % Repulsion Energy
    E_A_r = repulsive_Ac + repulsive_AAs + repulsive_ABs;
    E_B_r = repulsive_Bc + repulsive_BBs + repulsive_BAs;
    E_r = E_A_r + E_B_r;
    %     E_A_r = (1/2)*(linker_AAc_r + linker_AAs_r + linker_ABs_r + linker_AAs_r);
    %     E_B_r = (1/2)*(linker_BAc_r + linker_BAs_r + linker_BBs_r + linker_BBs_r);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculating percent duplex
    
    % Cross hybridization for particle A
    % Percent linker A cross hybridized
    duplex_AAc = (area_overlap_AB*NN_A_B/area_total_A)*restrict_area_A*restrict_linker_AAc;
    % Percent linker B cross hybridized
    duplex_ABc = (area_overlap_AB*NN_A_B/area_total_A)*restrict_area_A*restrict_linker_ABc;
    
    % Cross hybridization for particle B
    % Percent linker B cross hybridized
    duplex_BBc = (area_overlap_BA*NN_B_A/area_total_B)*restrict_area_B*restrict_linker_BBc;
    % Percent linker A cross hybridized
    duplex_BAc = (area_overlap_BA*NN_B_A/area_total_B)*restrict_area_B*restrict_linker_BAc;
    
    % Self hybridization for particle A
    % Percent linker A self hybridized
    duplex_AAs = (area_overlap_AA*NN_A_A/area_total_A)*restrict_area_A*restrict_linker_AAs;
    % Percent linker B self hybridized
    duplex_ABs = (area_overlap_AA*NN_A_A/area_total_A)*restrict_area_A*restrict_linker_ABs;
    
    % Self hybridization for particle B
    % Percent linker B self hybridized
    duplex_BBs = (area_overlap_BB*NN_B_B/area_total_B)*restrict_area_B*restrict_linker_BBs;
    % Percent linker A self hybridized
    duplex_BAs = (area_overlap_BB*NN_B_B/area_total_B)*restrict_area_B*restrict_linker_BAs;
    
    % Total duplex
    duplex_A = duplex_AAc + duplex_AAs + duplex_ABc + duplex_ABs;
    duplex_B = duplex_BBc + duplex_BBs + duplex_BAc + duplex_BAs;
    
    % Energy calculations
    E_A = -duplex_A*linker_AT*sigma + E_r;
    E_B = -duplex_B*linker_BT*sigma + E_r;
    
    % Grouping
    duplex{i} = [duplex_A duplex_B];
    E{i} = [E_A E_B];
end

% Calculating duplex
duplex_A = 0;
duplex_B = 0;
E_A = 0;
E_B = 0;
for i = 1:length(d_array)
    duplex_A = duplex_A + duplex{i}(1);
    E_A = E_A + E{i}(1);
    duplex_B = duplex_B + duplex{i}(2);
    E_B = E_B + E{i}(2);
end
% Grouping
E_t = [E_A E_B];
duplex_t = [duplex_A duplex_B];
E_final = max(E_t);
duplex_final = min(duplex_t);
end