% ===========================
% One-Class SVM Training
% ===========================

% Load features table
load('FeatureTable_SVM.mat', 'FeatureTable_SVM');             

rng("default")
Mdl = ocsvm(FeatureTable_SVM, StandardizeData=true, KernelScale="auto");




