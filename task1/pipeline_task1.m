% Preprocessing training and test data

%% Caricamento Dati e Modelli
run("..\trainigDataset.m")
run("..\testDataset.m")

% Features extraction
addpath('dataset\');
%***import generate_features_task1.*
import diagnosticFeatures128_10_5300_2_20.*
import aggregate_predictions_by_mode.*

% Carica il modello addestrato
%***load('bestModel.mat');
%load('trainingOutput_BaggedTrees.mat');
load('trainingOutput_Boosted.mat');


% Caricamento file delle risposte per confronto
answers = '../dataset/answer.csv';
answers = readtable(answers, 'VariableNamingRule', 'preserve');

%Frame Policy di 128ms
% Numero di finestre per campione(1200ms/128ms)
windowsPerSample = 10;

%Frame Policy di 160ms
% Numero di finestre per campione(1200ms/80ms)
%windowsPerSample = 8;


%% Addestramento

% **** Generazione delle feature dei dati di test del task 1 ****
%[testFeatureTable1, x1] = generate_features_task1(testData);
[testFeatureTable1, x1] = diagnosticFeatures128_10_5300_2_20(testData);
% Check the structure of trainedModel_task1
%whos bestModel

% Predizioni sulle feature del dataset di test
predictedLabelsArray = trainingOutput_Boosted.predictFcn(testFeatureTable1); % Salva le predizioni in un array

% Visualizza o salva i risultati
%disp(predictedLabelsArray);  % Visualizza le predizioni

% Stampa il numero di etichette predette
numPredictedLabels = numel(predictedLabelsArray);  % Numero di predizioni
disp(['Numero di etichette predette: ', num2str(numPredictedLabels)]);

% Salva le predizioni iniziali su un file CSV
%writetable(table(predictedLabelsArray), 'predictions_test_set.csv');


%% Sistema di voting con moda (1)

% Aggrega le predizioni per campione
predictedPerSample = aggregate_predictions_by_mode(predictedLabelsArray, windowsPerSample)';% trasposto

% Stampa il numero di predizioni finale
finalPredictionsNumber = numel(predictedPerSample);  % Numero di predizioni
disp(['Numero di etichette finali predette: ', num2str(finalPredictionsNumber)]);

% Visualizza o salva le predizioni finali
%disp('Predizioni per campione:');
%disp(predictedPerSample);

% Salva i risultati in un file CSV
%writetable(table(predictedPerSample), 'predictions_per_sample.csv');


count_normal = length(predictedPerSample(predictedPerSample == 0));   
count_abnormal = length(predictedPerSample(predictedPerSample == 1));
 
disp(['Data classified as normal (class 0): ', num2str(count_normal)]);
disp(['Data classified as abnormal (class 1): ' , num2str(count_abnormal)]);


%% Sistema di voting con threshold (2)
threshold = int32(windowsPerSample*2/3)+1;
len = length(predictedLabelsArray);
prediction = [];

for i = 1:windowsPerSample:len-windowsPerSample+1
            countOfOnes = sum(predictedLabelsArray(i:i+windowsPerSample-1) == 1);
            countOfZeros = windowsPerSample-countOfOnes;
            if countOfOnes>=threshold
                prediction = [prediction, 1];
            else
                prediction = [prediction, 0];
            end
end
    
count_normal = length(prediction(prediction == 0));   
count_abnormal = length(prediction(prediction == 1));
 
fprintf('Data classified as normal (class 0): %d \n', count_normal);
fprintf('Data classified as abnormal (class 1): %d \n', count_abnormal);
%% Calcolo delle Predizioni Corrette e dell'Accuracy per il Sistema Voting (1)
correct_answer_task1 = answers.task1';
rightPredic1 = correct_answer_task1 == predictedPerSample;

% Calculate accuracy
accuracy = (sum(rightPredic1) / numel(correct_answer_task1)*100);

% Display accuracy
disp(['Accuracy: ', num2str(accuracy), '%']);

% **** Rendering Confusion Matrix ****
classLabels = {'Normale', 'Anormale'};
C = confusionmat(correct_answer_task1, predictedPerSample);
figure;
confusionchart(C, classLabels);
title(['Totale Accuracy Task 1: ', num2str(accuracy), ' %']);
fig_name = 'figures/confusionmatrix1_task1';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, [fig_name, '.png']);

% **** Aggiunta id alle predizioni e traspone 'prediction1' ****
predictedPerSample = [answers.ID predictedPerSample'];

%% Calcolo delle Predizioni Corrette e dell'Accuracy per il Sistema Voting (2)
correct_answer_task1 = answers.task1';
rightPredic2 = correct_answer_task1 == prediction;

% Calculate accuracy
accuracy = (sum(rightPredic2) / numel(correct_answer_task1)*100);

% Display accuracy
disp(['Accuracy: ', num2str(accuracy), '%']);

% **** Rendering Confusion Matrix ****
classLabels = {'Normale', 'Anormale'};
C = confusionmat(correct_answer_task1, prediction);
figure;
confusionchart(C, classLabels);
title(['Totale Accuracy Task 1: ', num2str(accuracy), ' %']);
fig_name = 'figures/confusionmatrix2_task1';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, [fig_name, '.png']);

% **** Aggiunta id alle predizioni e traspone 'prediction1' ****
prediction = [answers.ID prediction'];
