%% Main GA code Sept 2013
function out = runGAonCCM(targetCrystalStructure)
% takes a string corresponding to a crystal name from the data and returns a set of parameters 
%% 
if(nargin<1)
    targetCrystalStructure = 'CsCl';
end

%% load database

global crystalData idx
% Creating compound name array
% Preallocation
crystalData = loadCrystalData(); 

%% check if input entered right?
idx = find(cellfun(@isempty,strfind(crystalData.names,targetCrystalStructure))-1);

while(isempty(idx))
    disp(crystalData.names);
    str = input(prompt,'s');
    idx = find(cellfun(@isempty,strfind(compound_name,str))-1);
end
%% define model space
dna_ratio_range = [.1 3];
size_ratio_range = [0.1 1];
rhoAA_range = [0 1];
rhoBB_range = [0 1];
sigma = 5; 

%%
%% define fitness function

%     function score = fitnessEvaluation(,
%     end

%% decide crystal targets

%% Set GA settings

settings.n_ind = 100;
settings.n_ger = 1000;
settings.elitism = 2/100; 
settings.cp = 0.8;
settings.mp = 0.2;


%% call GA
options = gaoptimset(@ga);
   options.PopulationSize = 100;
   options.Generations = 1000;
   options.PopInitRange = [0;300];
   options.MutationFcn = @mutationadaptfeasible;
   options.PlotFcns = @gaplotbestf;
   options = gaoptimset(options,'HybridFcn',{ @fmincon []}); 
 [x fval reason output finalpop finalscores] = ga(@modelga, 2,'','','','',[0.1 0], [3 200],'',options);
%% study convergences

compound_name = crystalData.names(idx);
out = crystalData
end