global crystStructParams crystalData % memoDB

crystalData = loadCrystalData(); 
crystStructParams = {crystalData.NNarr,crystalData.NParr,crystalData.dists};
varNames = cellfun(@(str) [str '.mat'],genvarname(crystalData.names),'UniformOutput',false);
sigma = 5; 
allOthers = {}; 
output = {};

%% get list of data files
listing = dir;
lst = struct2cell(listing);
datafiles = {}; 
for i = 1:length(lst)
    name = cellstr(lst{1,i});
    re = regexp(name,'\w*\.mat','match');
    
    if ~isempty(re)
        datafiles = [datafiles; re{1}];
    end
end

havedatap = @(vName) ismember(vName,datafiles); 

for k = 1:length(varNames)
   varName = varNames{k};
    if havedatap(varName)
    load(varName)
    others = toSave.finalpop; 
    otherNames = {}; 
    R = '';
 
    for i = 1:length(others)
        params = others(i,:); 
            dna_ratio = params(1);
         size_ratio = params(2);
         rho_AA = params(3);
         rho_BB = params(4); 
         NP_expA = params(5);
         NP_expB = params(6);
         comp = params(7); 
            [kmin,E,dev,E2] = CCM_NNfull(dna_ratio,size_ratio,rho_AA,rho_BB,sigma,[NP_expA,NP_expB],comp);
            
         
         
         
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
end


DS = cell2dataset(output,'VarNames',{'Goal' 'Pred' 'Params' 'Fval' 'Asymmetry' 'PopVariance' 'Other Structures'})

export(DS,'XLSfile','CCM_GA_RESULTS'); 