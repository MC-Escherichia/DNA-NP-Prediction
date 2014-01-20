global crystStructParams crystalData

crystalData = loadCrystalData(); 
crystStructParams = {crystalData.NNarr,crystalData.NParr,crystalData.dists};
varNames = genvarname(crystalData.names);
sigma = 5; 
allOthers = {}; 
output = {};
for k = 1:length(varNames)
   
    load([varNames{k} '.mat'])
    others = toSave.finalpop; 
    otherNames = {}; 
   R = '';
 
    for i = 1:length(others)
        params = others(i,:); 
          dna_ratio = params(1);
         size_ratio = params(2);
         rho_AA = params(3);
         rho_BB = params(4); 
        
         [kmin,E,dev,E2] = CCM_NNfull(dna_ratio,size_ratio,rho_AA,rho_BB,sigma);
         
         
         
         structOfOther = crystalData.names{kmin}; 
        otherNames = [otherNames , {structOfOther}];   
    end
    
    UotherNames = unique(otherNames); 
    
   
    C2 = UotherNames; % work on copy
    C2(2,:) = {', '};
    C2{2,end} = '';
    R = [C2{:}];
    allOthers = [allOthers,{others, otherNames}];
   
outrow = {crystalData.names{k} toSave.structPred toSave.x toSave.fval toSave.asymmetry toSave.popVar R};

output = [output;outrow];
end


DS = cell2dataset(output,'VarNames',{'Goal' 'Pred' 'Params' 'Fval' 'Asymmetry' 'PopVariance' 'Other Structures'})

export(DS,'XLSfile','CCM_GA_RESULTS'); 