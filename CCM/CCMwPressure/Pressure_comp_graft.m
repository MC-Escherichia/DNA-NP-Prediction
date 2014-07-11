% Thi Vo
% Columbia University
% Pressure Dependent Phase Transition

clear all; close all; clc;

% Defining sigma
sigma = 5;

% Cutoff
barrier = 0.5;

% Defining DNA ratio
dna_ratio = 1;%linspace(0.2,3,100);

% Defining size_ratio
size_ratio = 1;%linspace(0.2,1,100);

% Grafting array
graft = linspace(0,1,100);

% Compression
comp = linspace(0.2,1.2,100);
comp_m = 1;

% Stoich
% NP_exp = [4 1]; 

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
% d_array = [1; 1.15];
% d_array = 1;

% Preallocation
duplex1 = zeros(length(comp),length(graft));
cluster1 = zeros(length(comp),length(graft));
for i = 1:length(comp)
    comp_temp = comp(i);
    for j = 1:length(graft)
        rho_AA = graft(j);
        rho_BB = graft(j)-1E-8;
        [~,E,t] = CCM_NNmain(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma,NP_exp,comp_temp,comp_m);
        duplex1(i,j) = -E;
        if t > barrier
            cluster1(i,j) = 0;
        else
            cluster1(i,j) = -(E-1);
        end
    end
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
% d_array = [1; 1.414];
% d_array = 1;

% Preallocation
duplex2 = zeros(length(comp),length(graft));
cluster2 = zeros(length(comp),length(graft));
for i = 1:length(comp)
    comp_temp = comp(i);
    for j = 1:length(graft)
        rho_AA = graft(j);
        rho_BB = graft(j)-1E-8;
        [~,E,t] = CCM_NNmain(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma,NP_exp,comp_temp,comp_m);
        duplex2(i,j) = -E;
        if t > barrier
            cluster2(i,j) = 0;
        else
            cluster2(i,j) = -(E-1);
        end
    end
end

% Nearest neighbor array
NN_array = [0 12 4 8; 6 0 0 6; 0 24 8 16];
% Number of particle in lattice array
NP_array = [1 3];
% Experimental stoichiometry
NP_exp = NP_array;
% NP_exp = [1 4];
% Nearest neighbor distance array
d_array = [1; 1.414; 1.731];
% d_array = [1; 1.414];
% d_array = 1;

% Preallocation
duplex2a = zeros(length(comp),length(graft));
cluster2a = zeros(length(comp),length(graft));
for i = 1:length(comp)
    comp_temp = comp(i);
    for j = 1:length(graft)
        rho_AA = graft(j);
        rho_BB = graft(j)-1E-8;
        [~,E,t] = CCM_NNmain(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma,NP_exp,comp_temp,comp_m);
        duplex2a(i,j) = -E;
        if t > barrier
            cluster2a(i,j) = 0;
        else
            cluster2a(i,j) = -(E-1);
        end
    end
end

% NP_exp = [4 1];
% SC
% Nearest neighbor array
NN_array = [0 6 6 0; 12 0 0 12; 0 6 6 0];
% Number of particle in lattice array
NP_array = [1 1];
% Experimental stoichiometry
NP_exp = NP_array;
% Nearest neighbor distance array
d_array = [1; 1.414; 1.732];
% d_array = [1; 1.414];
% d_array = 1;

% Preallocation
duplex3 = zeros(length(comp),length(graft));
cluster3 = zeros(length(comp),length(graft));
for i = 1:length(comp)
    comp_temp = comp(i);
    for j = 1:length(graft)
        rho_AA = graft(j);
        rho_BB = graft(j)-1E-8;
        [~,E,t] = CCM_NNmain(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma,NP_exp,comp_temp,comp_m);
        duplex3(i,j) = -E;
        if t > barrier
            cluster3(i,j) = 0;
        else
            cluster3(i,j) = -(E-1);
        end
    end
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
% d_array = [1; 1.414];
% d_array = 1;

% Preallocation
duplex4 = zeros(length(comp),length(graft));
cluster4 = zeros(length(comp),length(graft));
for i = 1:length(comp)
    comp_temp = comp(i);
    for j = 1:length(graft)
        rho_AA = graft(j);
        rho_BB = graft(j)-1E-8;
        [~,E,t] = CCM_NNmain(dna_ratio,size_ratio,NN_array,NP_array,d_array,rho_AA,rho_BB,sigma,NP_exp,comp_temp,comp_m);
        duplex4(i,j) = -E;
        if t > barrier
            cluster4(i,j) = 0;
        else
            cluster4(i,j) = -(E-1);
        end

    end
end

colour = [0.7 0 0; 0 0.7 0; 0 0 0.7; 0.5252 0.0099 0.6939; 1 0 1; 0 1 1; 0.5 0.5 0.5; 1 0.62 0.40; 0 0 0];

fff = figure;
hAxs = axes('Parent',fff);
surf(graft,comp,duplex3,'FaceColor',colour(3,:),'EdgeColor','none','parent',hAxs);lighting phong;
hold on;
surf(graft,comp,duplex2,'FaceColor',colour(2,:),'EdgeColor','none','parent',hAxs);lighting phong;
surf(graft,comp,duplex1,'FaceColor',colour(1,:),'EdgeColor','none','parent',hAxs);lighting phong;
% surf(graft,comp,duplex4,'FaceColor',colour(4,:),'EdgeColor','none','parent',hAxs);lighting phong;
surf(graft,comp,duplex2a,'FaceColor',colour(2,:),'EdgeColor','none','parent',hAxs);lighting phong;
surf(graft,comp,cluster1,'FaceColor',colour(end,:),'EdgeColor','none','parent',hAxs);lighting phong;
surf(graft,comp,cluster2,'FaceColor',colour(end,:),'EdgeColor','none','parent',hAxs);lighting phong;
surf(graft,comp,cluster2a,'FaceColor',colour(end,:),'EdgeColor','none','parent',hAxs);lighting phong;
surf(graft,comp,cluster3,'FaceColor',colour(end,:),'EdgeColor','none','parent',hAxs);lighting phong;
% surf(graft,comp,duplex2a,'FaceColor',colour(2,:),'EdgeColor','none','parent',hAxs);lighting phong;
% legend('SC','FCC','BCC','CuAu')
legend('SC','FCC','BCC')
ylabel('Compression')
xlabel('Grafting Fraction')
axis([min(graft) max(graft) min(comp) max(comp)])
view([0,90])