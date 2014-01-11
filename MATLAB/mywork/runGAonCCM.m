%% Main GA code Sept 2013
function out = runGAonCCM(targetCrystalStructure)
% takes a string corresponding to a crystal name from the data and returns a set of parameters 
%% 

global crystalData  sigma memoDB

crystalData = loadCrystalData; 
if(nargin<1)
    targetCrystalStructure = 'CsCl';
end



%% check if input entered right?
idx = find(cellfun(@isempty,strfind(crystalData.names,targetCrystalStructure))-1);

while(isempty(idx))
    disp(crystalData.names);
    str = input(prompt,'s');
    idx = find(cellfun(@isempty,strfind(compound_name,str))-1);
end
%% define model space
dna_ratio_range = [.1 3];
size_ratio_range = [0.1 10];
rhoAA_range = [0 1];
rhoBB_range = [0 1];
sigma = 5; 

bounds = [dna_ratio_range ;size_ratio_range ;rhoAA_range;rhoBB_range];
lbs = bounds(:,1)';
ubs = bounds(:,2)'; 

% convert bounds on parameters to single precision numbers 
lbs = single(lbs);
ubs = single(ubs); 

%% asymmetry scaling function
steepness = 25; % making this larger increases the steepness of the sigmoid. 
asym = @(deviate) 1./(1+exp(-steepness.*(deviate-0.5)));  
enDiff  = @(Eratio) (exp(steepness.*Eration)-1)./(exp(steepness)-1);

%% define fitness function
    NPdes = crystalData.NParr{idx}; 
    NNdes = crystalData.NNarr{idx};
    function s = score(k, dev, r)
        NPobt = crystalData.NParr{k}; 
         NNobt = crystalData.NNarr{k};
         s = norm(NNdes-NNobt) + norm(NPdes-NPobt) + asym(dev) + enDiff(E./E2);  
    end
     function scores = fitnessEvaluation(params)
         dna_ratio = params(1);
         size_ratio = params(2);
         rho_AA = params(3);
         rho_BB = params(4); 
            [kmin,E,dev,E2] = CCM_NNfull(dna_ratio,size_ratio,rho_AA,rho_BB,sigma);
         
         
         scores = score(kmin,dev,E2./E); 
       
        
      end

%% decide crystal targets

%% Find up to 40 good candidates from previous search

entryset = memoDB.entrySet;
it = entryset.iterator; 
popList = {};
while it.hasNext
    entry = it.next; 
    [k_e, dev_e, r_e] = entry.getValue; 
    s = score(k_e,dev_e,r_e);
    
    if(size(popList,2)<=20)
        popList=sortrows([popList;{entry.getKey s}],2);
        
               
    elseif(popList{end,2}>s)
        popList = sortrows([popList;{entry.getKey s}],2);
        popList = popList(1:end-1,:);
        
    end
end

popList = cell2mat(cellfun(@(strn) eval(['double(' strn ')']),popList{1,:})); 
%% Set GA settings


options = gaoptimset(@ga);
   options.PopulationSize = 100;
   options.Generations = 300;
   options.PopulationType = 'doubleVector'; 
   options.InitialPopulation = popList; 
   options.PopInitRange = [0;300];
   options.MutationFcn = @mutationadaptfeasible;
   options.PlotFcns = @gaplotbestf;
   options.UseParallel = 'always'; 
   options.Vectorized = 'on'; 
   options = gaoptimset(options,'HybridFcn',{ @fmincon []}); 
   %% call GA

   
 [x fval reason output finalpop finalscores] = ga(@fitnessEvaluation, 4,'','','','',lbs, ubs,'',options);
 
 
%% study convergences
structPred = crystalData.names{kmin};
asymmetry = dev; 

out =  v2struct(structPred, x ,fval ,reason ,output ,finalpop, finalscores, asymmetry) ;
end