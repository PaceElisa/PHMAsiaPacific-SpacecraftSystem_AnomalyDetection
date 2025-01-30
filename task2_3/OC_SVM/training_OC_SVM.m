% ===========================
% One-Class SVM Training
% ===========================

% load features table
load('FeatureTable_OCSVM.mat', 'FeatureTable_OCSVM');       

rng("default") 
Mdl = ocsvm(FeatureTable_OCSVM, StandardizeData=true, KernelScale="auto");




