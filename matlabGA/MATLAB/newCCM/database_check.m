% Thi Vo
% Columbia University
% Database Search Check - Updated CCM

clear all; close all; clc;

cd('C:\Users\Thi\Documents\School\Research\CCM w n nearest neighbors')

% Reading Excel Database
[~,text] = xlsread('Crystal Database New.xlsx');

% Creating compound name array
% Preallocation
compound_name = cell(length(text)-3,1);
for i = 4:length(text)
    compound_name{i-3} = text{i,1};
end

% Setting up array
% Size Ratio
R_s_array = 0.4:0.1:1.0;
% Linker Ratio
R_l_array = 0.5:0.1:2.6;
% Grafting density
rho_AA = linspace(0.0,1,50);
rho_BB = linspace(0.0,1,50);

% Creating array of folder name
str1 = 'R_s = ';
str3 = ' R_l = ';
ext1 = '.dat';
str10 = 'Cycle Number ';
str11 = '';
% Opening write file
fid = fopen('Dominant Phases.txt', 'wt');

% Preallocation
data = cell(length(compound_name),1);
for i = 1:length(R_s_array)
    ext10 = num2str(i);
    cyclenum = strcat(str10,str11,ext10);
    disp(cyclenum)
    for j = 1:length(R_l_array)
        disp(j)
        R_s = R_s_array(i);
        str2 = num2str(R_s);
        R_l = R_l_array(j);
        str4 = num2str(R_l);
        folder_name = strcat(str1,str2,str3,str4);
        cd(folder_name)
        for k = 1:length(compound_name)
            file_name = strcat(compound_name{k},ext1);
            data{k} = importfile(file_name);
        end
        % Preallocations
        counter = 0;
        test = 1E10;
        dominant = cell(length(rho_AA),length(rho_BB));
        for a = 1:length(rho_AA)
            for b = 1:length(rho_BB)
                for c = 1:length(compound_name)
                    energy = data{c}(a,b);
                    if energy < test
                        compound = compound_name{c};
                        test = energy;
                    end
                end
                dominant{a,b} = compound;
                test = 1E10;
            end
        end
        dominant_f = unique(dominant);
        %open file with write permission
        %write a line of text
        fprintf(fid, '%s\n', folder_name);
        fprintf(fid, '%s\n', '');
        for zz = 1:length(dominant_f)
            fprintf(fid, '%s\n', dominant_f{zz});
        end
        fprintf(fid,'%s\n','');
        
        % write separate file to folder - allows for plotting later
        ffile = fopen('Dominant.txt','wt');
        for zz = 1:length(dominant_f)
            fprintf(ffile, '%s\n', dominant_f{zz});
        end
        fclose(ffile);
        
        cd ./..
    end
end

fclose(fid);