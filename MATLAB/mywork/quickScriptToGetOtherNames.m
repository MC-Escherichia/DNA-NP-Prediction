global crystStructParams 

crystalData = loadCrystalData(); 
crystStructParams = {crystalData.NNarr,crystalData.NParr,crystalData.dists};
sigma = 5; 
allOthers = {}; 
for k = 1:length(varNames)
   
    others = collecting.(varNames{k}).finalpop;
    otherNames = {}; 
    for i = 1:length(others)
        params = others(i,:); 
          dna_ratio = params(1);
         size_ratio = params(2);
         rho_AA = params(3);
         rho_BB = params(4); 

         
         [duplex_f,E_f,test,dev,duplexf,Ef,kmax,Ef2] = CCM_NNmain(crystStructParams,dna_ratio,size_ratio,rho_AA,rho_BB,sigma);
         
         structOfOther = crystalData.names{kmax}; 
        otherNames = [otherNames , {structOfOther}];   
    end
    
    otherNames = unique(otherNames); 
    
   
C2 = otherNames; % work on copy
C2(2,:) = {', '};
C2{2,end} = '';
R = [C2{:}];
allOthers = [allOthers,{R}];


end

[allOthers{:}]'