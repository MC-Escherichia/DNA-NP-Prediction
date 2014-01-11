%% Meta GA analysis


%% load library

global crystalData idx memoDB
% Creating compound name array

crystalData = loadCrystalData(); 
memoDB = java.util.concurrent.ConcurrentHashMap; 


%% loop through all crystals in database

% keep track of 
% 1. success? true/false there is configuration that predicts this
% structure
% 2. Asymmetry more than 0.5 means cluster formation and not real
% crystallization
% 3. final population variation 
initialized = false;
varNames = genvarname(crystalData.names); 

if  matlabpool('size') == 0 % parallel pool needed
    matlabpool % create the parallel pool
end
   
for k = 1:length(crystalData.names)
    structure = crystalData.names{k}; 
modelOutput = runGAonCCM(structure);

collecting.(varNames{k}) = modelOutput;

collecting.(varNames{k}).goalStruct = structure; 


collecting.(varNames{k}).popVar = norm(std(modelOutput.finalpop,0,1)); 
toSave = collecting.(varNames{k});
save([varNames{k} '.mat'],'toSave'); 

end

if  matlabpool('size') > 0 % parallel pool exists
    matlabpool('close') % delete the pool
end