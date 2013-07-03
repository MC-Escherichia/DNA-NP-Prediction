function [scores] = modelga(x)
global ndata crystl d_k  NN_A NN_B NP_A NP_B NP_Radius_A NP_Radius_B
DNA_Ratio = x(1);
Extra_Base_Pair = x(2);
[a,b] = size(ndata);

for k = 1:a
[crystl.Size_Ratio(k) crystl.DNA_Max_A(k) crystl.DNA_Max_B(k)...
    crystl.Circle_Radius(k) crystl.Height_A(k) crystl.Height_B(k)...
    crystl.Overlap_A(k) crystl.Overlap_B(k) crystl.Surface_Area_A(k) ...
    crystl.Surface_Area_B(k) crystl.DNA_Duplexed_A(k) crystl.DNA_Duplexed_B(k)...
    crystl.Percent_Duplexed(k) ] = ...
    crystlstblty(NP_Radius_A,NP_Radius_B,Extra_Base_Pair,DNA_Ratio,NN_A(k),...
        NN_B(k),NP_A(k),NP_B(k));
end

[score_top,score_index] = max(crystl.Percent_Duplexed);
NP_obt = NP_A(score_index);
NP_des = NP_A(d_k);

[crystl.des_Size_Ratio crystl.des_DNA_Max_A crystl.des_DNA_Max_B ...
    crystl.des_Circle_Radius crystl.des_Height_A crystl.des_Height_B ...
    crystl.des_Overlap_A crystl.des_Overlap_B crystl.des_Surface_Area_A ...
    crystl.des_Surface_Area_B crystl.des_DNA_Duplexed_A crystl.des_DNA_Duplexed_B ...
    crystl.des_Percent_Duplexed ] = ...
        crystlstblty(NP_Radius_A,NP_Radius_B,Extra_Base_Pair,DNA_Ratio,...
        NN_A(d_k),NN_B(d_k),NP_A(d_k),NP_B(d_k));

score_desired = max(crystl.des_Percent_Duplexed);
scores = (score_top-score_desired)^2+0.1*(NP_obt - NP_des)^2;
%scores = (score_top-score_desired)^2;
