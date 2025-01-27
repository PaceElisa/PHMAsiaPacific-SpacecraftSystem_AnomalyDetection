%% Caricamento Dati e Modelli
import train_test_split.*
%import diagnosticFeatures20.*
run("..\trainigDataset.m")

%% Apri il diagnostic feature designer con il dataset challenge dataset ottenuto poi salva lo script come 
% diagnosticFeaturen dove n sono il numero di feature estratte poi esegui
% codice sotto e fai lo split del dataset ottenuto
%% Generazione delle feature Frame Policy = 0.128ms
% num windows frame policy 0.128s
%numWindow = 10;
%num windows frame policy 0.080s
numWindow = 15;

% **** Generazione delle feature dei dati di test del task 1 ****
%[testFeatureTable1, x1] = diagnosticFeatures(challengeDataset);
[testFeatureTable1, x1] = diagnosticFeatures25(challengeDataset);

% **** Split dei dati di training per la validazione del task 1 ****
[trainingTB,testingTB]  = train_test_split(testFeatureTable1,numWindow);
%[trainingTB,testingTB]  = train_test_split(FeatureTable1,numWindow);

% Apri il Classification Learner e addestra il modello con i dati di
% trainingTB, mettilo al posto di trainedModel e poi testa con quelli di
% testingTB aprendo lo script pipeline_task1

