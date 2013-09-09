clear all; close all; clc;

% Input
% dna_ratio: DNA ratio array
% dna_increase: DNA linker length increase array
% NN_A: nearest neighbor A
% NN_B: nearest neighbor B
% NP_A: number of particle A
% NP_B: number of particle B

% Output
% duplex: duplex formation percentage
% size_raio: DNA-NP size ratio

% Defining DNA linker ratio
dna_ratio = linspace(0.1,3,300);

% Defining linker size increase
dna_increase = linspace(0,160,500);

% Defining grafting fraction
rho_AA = 0;
rho_AB = 1 - rho_AA;
rho_BB = 1;
rho_BA = 1 - rho_BB;

% Paramters
NN_A = 8;
NN_B = 8;
NP_A = 1;
NP_B = 1;

% NN_A = 4;
% NN_B = 12;
% NP_A = 3;
% NP_B = 1;

% NN_A = 6;
% NN_B = 12;
% NP_A = 2;
% NP_B = 1;
% Preallocation
duplex = zeros(length(dna_ratio),length(dna_increase));
size_ratio = zeros(length(dna_ratio),length(dna_increase));

% DNA parameters
dna_ideal = 0.255;
dna_max = 0.34;

% Nano-particle base parameters
rad_NP_A = 5.4;
rad_NP_B = 5.4;
DNA_A = 32;
linker_AT = 200;

for i = 1:length(dna_ratio)
    for j = 1:length(dna_increase)
        DNA_B = (DNA_A + dna_increase(j));
        rad_A = rad_NP_A + DNA_A*dna_ideal;
        rad_B = rad_NP_B + DNA_B*dna_ideal;
        size_ratio(i,j) = rad_A/rad_B;
        rad_max_A = rad_NP_A + DNA_A*dna_max;
        rad_max_B = rad_NP_B + DNA_B*dna_max;
        d_NP_core = rad_A + rad_B;
        r_overlap = (1/(2*d_NP_core))*sqrt(4*d_NP_core^2*rad_max_B^2 - (d_NP_core^2 + rad_max_B^2 - rad_max_A^2)^2);
        h_overlap_A = rad_max_A - sqrt(rad_max_A^2 - r_overlap^2);
        h_overlap_B = rad_max_B - sqrt(rad_max_B^2 - r_overlap^2);
        area_overlap_A = pi*(r_overlap^2 + h_overlap_A^2);
        area_overlap_B = pi*(r_overlap^2 + h_overlap_B^2);
        area_total_A = 4*pi*rad_max_A^2;
        area_total_B = 4*pi*rad_max_B^2;
        linker_AA = linker_AT*rho_AA;
        linker_AB = linker_AT*rho_AB;
        linker_BT = linker_AT*dna_ratio(i);
        linker_BB = linker_BT*rho_BB;
        linker_BA = linker_BT*rho_BA;
        % Defining crystal lattice
        % Restriction due to number of nearest neighbors
        if (area_total_A/NN_A < area_overlap_A)
            restrict_area_A = (area_total_A/NN_A)/area_overlap_A;
        else
            restrict_area_A = 1;
        end
        % Restriction due to number of nearest neighbors
        if (area_total_B/NN_B < area_overlap_B)
            restrict_area_B = (area_total_B/NN_B)/area_overlap_B;
        else
            restrict_area_B = 1;
        end
        % Restriction due to number of linker A(B) grafted onto A(B)
        if (linker_AA*NP_A > linker_BB*NP_B)
            restrict_linker_AA = linker_BB*NP_B/(linker_AT*NP_A);
            restrict_linker_BB = 1;
        else
            restrict_linker_AA = 1;
            restrict_linker_BB = linker_AA*NP_A/(linker_BT*NP_B);
        end
        % Restriction due to number of linker A(B) grafted onto B(A)
        if (linker_AB*NP_A > linker_BA*NP_B)
            restrict_linker_AB = linker_BA*NP_B/(linker_AT*NP_A);
            restrict_linker_BA = 1;
            
        elseif (linker_BA*NP_B > linker_AB*NP_A)
            restrict_linker_AB = 1;
            restrict_linker_BA = linker_AB*NP_A/(linker_BT*NP_B);
            
        else
            restrict_linker_AB = 0;
            restrict_linker_BA = 0;
            
        end
        duplex_AA = (area_overlap_A*NN_A/area_total_A)*restrict_area_A*restrict_linker_AA;
        duplex_AB = (area_overlap_A*NN_A/area_total_A)*restrict_area_A*restrict_linker_AB;
        duplex_A = duplex_AA + duplex_AB;
        duplex_BB = (area_overlap_B*NN_B/area_total_B)*restrict_area_B*restrict_linker_BB;
        duplex_BA = (area_overlap_B*NN_B/area_total_B)*restrict_area_B*restrict_linker_BA;
        duplex_B = duplex_BB + duplex_BA;
        if duplex_A > duplex_B
            duplex(i,j) = duplex_B;
        else
            duplex(i,j) = duplex_A;
        end
    end
end
duplex1 = duplex;

f = figure;
hAxs = axes('Parent',f);
colour = [0 0.7009 0; 0.6252 0.0099 0.7939; 0.7666 0.0149 0.0174; 0.1932 0.3139 0.9477];

surf(size_ratio,dna_ratio,duplex1,'FaceColor',colour(1,:),'EdgeColor','none','parent',hAxs);lighting phong;
hold on;
% surf(size_ratio,dna_ratio,duplex2,'FaceColor',colour(2,:),'EdgeColor','none','parent',hAxs);lighting phong;
% hold on;

beta = -1;
brighten(beta);
camlight headlight
% camlight right
% camlight left
% camlight(10,20)
xlabel('Size Ratio'); ylabel('DNA Ratio'); zlabel('% Duplexed DNA');