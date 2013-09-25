function [overlap_array, area_total_array] = area_overlap(dna_increase,d)
% Input
% dna_increase: DNA linker length increase array
% d: nearest neighbor distance (normalized by first nearest neighbor)

% Output

% DNA parameters
% dna_ideal: ideal length per DNA base
% dna_max: maximum length per DNA base
dna_ideal = 0.255;
dna_max = 0.34;

% Nano-particle base parameters
% rad_NP_A: radius of nanoparticle A
% rad_NP_B: radius of nanoparticle B
% DNA_A: number of DNA base on linker A
% linker_AT: total number of linkers on particle A
rad_NP_A = 5.4;
rad_NP_B = 5.4;
DNA_A = 32;

% Radius of DNA grafted particle A
rad_A = rad_NP_A + DNA_A*dna_ideal;
% Max radius of DNA grafted particle A
rad_max_A = rad_NP_A + DNA_A*dna_max;
% Number of DNA base on linker B
DNA_B = DNA_A + dna_increase;
% Radius of DNA grafted particle B
rad_B = rad_NP_B + DNA_B*dna_ideal;
% Max radius of DNA grafted particle B
rad_max_B = rad_NP_B + DNA_B*dna_max;
% Distance between nanoparticle cores
d_NP_core_AA = (rad_A + rad_A)*d;
d_NP_core_AB = (rad_A + rad_B)*d;
d_NP_core_BB = (rad_B + rad_B)*d;
% Radius of overlap region between nanoparticles

r_overlap_AB = (1/(2*d_NP_core_AB))*sqrt(4*d_NP_core_AB^2*rad_max_B^2 - (d_NP_core_AB^2 + rad_max_B^2 - rad_max_A^2)^2);
r_overlap_AA = sqrt(rad_max_A^2 - (d_NP_core_AA/2)^2);
r_overlap_BB = sqrt(rad_max_B^2 - (d_NP_core_BB/2)^2);
r_overlap_AB = real(r_overlap_AB);
r_overlap_AA = real(r_overlap_AA);
r_overlap_BB = real(r_overlap_BB);
% Height of overlap region
h_overlap_AA = rad_max_A - sqrt(rad_max_A^2 - r_overlap_AA^2);
h_overlap_AB = rad_max_A - sqrt(rad_max_A^2 - r_overlap_AB^2);
h_overlap_BA = rad_max_B - sqrt(rad_max_B^2 - r_overlap_AB^2);
h_overlap_BB = rad_max_B - sqrt(rad_max_B^2 - r_overlap_BB^2);
% Area of overlap region
area_overlap_AA = pi*(r_overlap_AA^2 + h_overlap_AA^2);
area_overlap_AB = pi*(r_overlap_AB^2 + h_overlap_AB^2);
area_overlap_BA = pi*(r_overlap_AB^2 + h_overlap_BA^2);
area_overlap_BB = pi*(r_overlap_BB^2 + h_overlap_BB^2);
% Grouping into arrays
overlap_array = [area_overlap_AA area_overlap_AB area_overlap_BA area_overlap_BB];
% Total area
area_total_A = 4*pi*rad_max_A^2;
area_total_B = 4*pi*rad_max_B^2;
% Group into array
area_total_array = [area_total_A area_total_B];
end