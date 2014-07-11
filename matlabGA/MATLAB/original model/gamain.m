close all
clear all;
clc


global ndata crystl d_k NN_A NN_B NP_A NP_B NP_Radius_A NP_Radius_B
[ndata, text, alldata] = xlsread('crystalwhole1.xlsx');
crystl.names = text(2:end,1);
crystl.na= ndata(:,1);
crystl.nb= ndata(:,2);
crystl.prta= ndata(:,3);
crystl.prtb= ndata(:,4);
%crystl.coorda= ndata(:,5);
%crystl.coordb= ndata(:,6);
ndata_cruc = ndata(:,1:4);
d_k= 54;


NN_A = crystl.na;
NN_B = crystl.nb;
NP_A= crystl.prta;
NP_B = crystl.prtb;
NP_Radius_A = 10;
NP_Radius_B = 10;

 options = gaoptimset(@ga);
  options.PopulationSize = 100;
  options.Generations = 1000;
  options.PopInitRange = [0;300];
  options.MutationFcn = @mutationadaptfeasible;
  options.PlotFcns = @gaplotbestf
 %options = gaoptimset(options,'HybridFcn',{ @fmincon []}); 
[x fval reason output finalpop finalscores] = ga(@modelga, 2,'','','','',[0.1 0], [3 200],'',options);

%Extra_Base_Pair = 117.7233;
Extra_Base_Pair = x(2);
%DNA_Ratio = 1.8449;
DNA_Ratio = x(1);
[a,b] = size(ndata);
for k = 1:a
[crystl.Size_Ratio(k) crystl.DNA_Max_A(k) crystl.DNA_Max_B(k) crystl.Circle_Radius(k) crystl.Height_A(k) crystl.Height_B(k) crystl.Overlap_A(k) crystl.Overlap_B(k) crystl.Surface_Area_A(k) crystl.Surface_Area_B(k) crystl.DNA_Duplexed_A(k) crystl.DNA_Duplexed_B(k) crystl.Percent_Duplexed(k) ] = crystlstblty(NP_Radius_A,NP_Radius_B,Extra_Base_Pair,DNA_Ratio,NN_A(k),NN_B(k),NP_A(k),NP_B(k));
end

[score_top,score_index] = max(crystl.Percent_Duplexed);
NP_obt = NP_A(score_index);
NP_des = NP_A(d_k);
[crystl.des_Size_Ratio crystl.des_DNA_Max_A crystl.des_DNA_Max_B crystl.des_Circle_Radius crystl.des_Height_A crystl.des_Height_B crystl.des_Overlap_A crystl.des_Overlap_B crystl.des_Surface_Area_A crystl.des_Surface_Area_B crystl.des_DNA_Duplexed_A crystl.des_DNA_Duplexed_B crystl.des_Percent_Duplexed ] = crystlstblty(NP_Radius_A,NP_Radius_B,Extra_Base_Pair,DNA_Ratio,NN_A(d_k),NN_B(d_k),NP_A(d_k),NP_B(d_k));
score_desired = max(crystl.des_Percent_Duplexed);
scores1 = (score_top - score_desired)^2+(NP_obt - NP_des)^2;
%scores1 = (score_top - score_desired)^2;
%scores = 100*(score_top-score_desired)^2 - score_top;
