function [Size_Ratio DNA_Max_A DNA_Max_B Circle_Radius Height_A Height_B Overlap_A Overlap_B Surface_Area_A Surface_Area_B DNA_Duplexed_A DNA_Duplexed_B Percent_Duplexed ] = crystlstblty(NP_Radius_A,NP_Radius_B,Extra_Base_Pair,DNA_Ratio,NN_A,NN_B,NP_A,NP_B)
NP_B = NP_B;
Max_DNA = 0.34;
DNA_Length_A = (0.255* 32) + NP_Radius_A;
% Define DNA_Length_B = (Ideal_DNA) * (32 + d) + (NP_Radius_B)
DNA_Length_B = (0.255 * (32 + Extra_Base_Pair)) + NP_Radius_B;
%Define Size_Ratio = (DNA_Length_A) / ( DNA_Length_B)
Size_Ratio = DNA_Length_A / DNA_Length_B;
%Define NP_Distance = (DNA_Length_A) + (DNA_Length_B)
NP_Distance = DNA_Length_A + DNA_Length_B;
% Define DNA_Max_A = ((Max_DNA) * (32)) + (NP_Radius_A)
DNA_Max_A = (Max_DNA * 32) + NP_Radius_A;    %doesn't have to be in the loop
% Define DNA_Max_B = ((Max_DNA) * (32 + d)) + (NP_Radius_B)
DNA_Max_B = (Max_DNA * (32 + Extra_Base_Pair)) + NP_Radius_B;
%Define Circle_Radius = (1/(2 * NP_Distance)) * SQRT((4 * NP_Distance^2 * DNA_Max_B^2) – (NP_Distance^2 - DNA_Max_A^2 + DNA_Max_B^2)^2)
Circle_Radius = (1/(2 * NP_Distance)) * sqrt((4 * NP_Distance^2 * DNA_Max_B^2) - (NP_Distance^2 - DNA_Max_A^2 + DNA_Max_B^2)^2);
% Define Height_A = DNA_Max_A - SQRT(DNA_Max_A^2 - Circle_Radius^2)
Height_A = DNA_Max_A - sqrt(DNA_Max_A^2 - Circle_Radius^2);
% Define Height_B = DNA_Max_B - SQRT(DNA_Max_B^2 - Circle_Radius^2)
Height_B = DNA_Max_B - sqrt(DNA_Max_B^2 - Circle_Radius^2);
% Define Overlap_A = 2 * pi * DNA_Max_A * Height_A
Overlap_A = 2 * pi * DNA_Max_A * Height_A;
% Define Overlap_B = 2 * pi * DNA_Max_B * Height_B
Overlap_B = 2 * pi * DNA_Max_B * Height_B;
% Define Surface_Area_A = 4 * pi * DNA_Max_A^2
Surface_Area_A = 4 * pi * (DNA_Max_A^2);
% Define Surface_Area_B = 4 * pi * DNA_Max_B^2
Surface_Area_B = 4 * pi * (DNA_Max_B^2);

Surface_Density_A = Surface_Area_A / DNA_Ratio;

%===========================================
if Overlap_A < (Surface_Area_A/NN_A)
    if NP_A > DNA_Ratio
        DNA_Duplexed_A = (NN_A * Overlap_A * DNA_Ratio) / (Surface_Area_A * NP_A);
    else
        DNA_Duplexed_A = (NN_A * Overlap_A) / Surface_Area_A;
    end
else
    if NP_A > DNA_Ratio
        DNA_Duplexed_A = DNA_Ratio / NP_A;
    else
        DNA_Duplexed_A = 1;
    end
end

if NP_A > DNA_Ratio
    DNA_Duplexed_B = (NN_B * Overlap_B) / Surface_Area_B;
else
    DNA_Duplexed_B = ((NN_B * Overlap_B) / Surface_Area_B) * (NP_A / DNA_Ratio);
end

if DNA_Duplexed_A > DNA_Duplexed_B;
    Percent_Duplexed = DNA_Duplexed_B;
else
    Percent_Duplexed = DNA_Duplexed_A;
end








