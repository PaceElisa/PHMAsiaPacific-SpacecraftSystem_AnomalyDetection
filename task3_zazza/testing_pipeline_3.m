% Loading of the test dataset composed of bubble contamination anomalies, obtained by filtering
% the results obtained by task 2
load("./preprocessingData/filteredTestSet.mat", "filteredTestSet"); 
disp( [newline '__Task3__']);
disp(['Number of samples in the test set: ', num2str(height(filteredTestSet))]);

% loading of the table with predictions
load("./preprocessingData/predictionsTable.mat", "predictionsTable");

% Loading of feature extraction function 
addpath('./featuresExtraction/');
import featuresExtraction_task3_function.*

% Loading pre-trained model
load('./training/trainedModel.mat', 'trainedModel');


%% Bubble Contamination Anomalies Classification

% Features Extraction
[testFeatureTable, x1] = featuresExtraction_task3_function(filteredTestSet);

% Prediction using pre-trained model
predictedLabelsArray = trainedModel.predictFcn(testFeatureTable); 


%% Voting system (1) based on the mode, such that each sample is assigned the most frequent label among the 10 mentioned
windowsPerSample = 10;

function finalPredictions = voting_system_task3(predictions, numWindow)
% VOTING_SYSTEM_TASK3 - Aggrega le predizioni per il Task 3 utilizzando il metodo della maggioranza
%
% INPUT:
%   predictions - Array con le predizioni finestrate
%   numWindow   - Numero di finestre per ogni campione
%
% OUTPUT:
%   finalPredictions - Array di predizioni aggregate per ogni campione

    % Calcola il numero totale di campioni
    numSamples = length(predictions) / numWindow;
    finalPredictions = zeros(numSamples, 1);

    % Aggregazione delle predizioni per ogni campione
    for i = 1:numSamples
        startIdx = (i - 1) * numWindow + 1;  % Indice di inizio
        endIdx = i * numWindow;              % Indice di fine
        samplePredictions = predictions(startIdx:endIdx);

        % Seleziona la classe più frequente nella finestra
        finalPredictions(i) = mode(samplePredictions);
    end
end

% Aggregates predictions for sample
predictedPerSample = voting_system_task3(predictedLabelsArray, windowsPerSample)';

% Update the prediction table with bubble anomalies
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 1)) = 1; % BP1
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 2)) = 2; % BP2
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 3)) = 3; % BP3
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 4)) = 4; % BP4
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 5)) = 5; % BP5
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 6)) = 6; % BP6
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 7)) = 7; % BP7
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 8)) = 8; % BV1

writetable(predictionsTable, 'predictions.csv');

%% Performance Evaluation

% Loading answers' file to compare true and predicted labels
answers = "./answer.csv";
answers = readtable(answers, 'VariableNamingRule', 'preserve');
trueLabels = answers.task3; 
predictedLabels = predictionsTable.Predictions;

% Accuracy calculation
numCorrect = sum(predictedLabels == trueLabels, 'omitnan');
accuracy = numCorrect / numel(trueLabels) * 100;
disp(['Model Accuracy: ', num2str(accuracy), '%']);

% Confusion Matrix

classLabels = {'Other', 'BP1', 'BP2', 'BP3', 'BP4', 'BP5', 'BP6', 'BP7'};
C = confusionmat(trueLabels, predictedLabels);
figure;
subplot(1,2,1);
confusionchart(C, classLabels);
sgtitle('Testing - Task 3', 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 20);
title(['Total Accuracy Task 3 pipeline: ', num2str(accuracy), '%']);

saveas(gcf, './confusion_matrix.png');