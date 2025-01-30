% ===========================
% One-Class SVM Training
% ===========================

% load features table
load('FeatureTable_SVM.mat', 'FeatureTable_SVM'); 

% Train the OC-SVM model
%ocSVM = fitcsvm(FeatureTable_SVM(:,2:end), 'Label', ...
%                'KernelFunction', 'gaussian', ...  % Kernel RBF
%                'KernelScale', 'auto', ...         % Automatic scaling of features
%                'OutlierFraction', 0.01, ...       % Assumes 5% as an outlier
%                'Standardize', true, ...           % Standardize the data
%                'Nu', 0.01, ...
%                'Verbose', 1);            

rng("default") % Per riproducibilità
Mdl = ocsvm(FeatureTable_SVM, StandardizeData=true, KernelScale="auto");




