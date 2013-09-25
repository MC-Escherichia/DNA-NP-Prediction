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

bounds = [dna_ratio_range ;size_ratio_range ;rhoAA_range;rhoBB_range];
lbs = bounds(:,1)';
ubs = bounds(:,2)'; 
crystStructParams = {crystalData.NNarr,crystalData.NParr,crystalData.dists};
%% asymmetry scaling function
steepness = 25; % making this larger increases the steepness of the sigmoid. 
asym = @(deviate) 1./(1+exp(-steepness.*(deviate-0.5)));  

%% define fitness function
    NPdes = crystalData.NParr{idx}; 

     function scores = fitnessEvaluation(params)
         dna_ratio = params(1);
         size_ratio = params(2);
         rho_AA = params(3);
         rho_BB = params(4); 

         
         [duplex_f,E_f,test,dev,duplexf,Ef,kmax] = CCM_NNmain(crystStructParams,dna_ratio,size_ratio,rho_AA,rho_BB,sigma);
         NPobt = crystalData.NParr{kmax}; 
         
         scores = (idx-kmax).^2 + 0.1*norm(NPdes-NPobt) + asym(dev); 
     end

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
 [x fval reason output finalpop finalscores] = ga(@fitnessEvaluation, 4,'','','','',lbs, ubs,'',options);
%% study convergences


out =  {x fval reason output finalpop finalscores} ;
end