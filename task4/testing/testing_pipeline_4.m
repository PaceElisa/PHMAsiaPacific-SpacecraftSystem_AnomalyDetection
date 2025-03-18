% Loading of the test dataset composed of valve faults, obtained by filtering
% the results obtained by task 2
load("../preprocessingData/filteredTestSet.mat", "filteredTestSet");
disp( [newline '__Task4__']);
disp(['Number of samples in the test set: ', num2str(height(filteredTestSet))]);

% loading of the table with predictions
load("../preprocessingData/predictionsTable.mat", "predictionsTable");

% Loading of feature extraction function 
addpath('../featuresExtraction/');
import featuresExtraction_task4_function.*

% Loading pre-trained model
load('../training/trainedModel.mat', 'trainedModel');


%% Valve Faults Classification

% Features Extraction
[testFeatureTable, x1] = featuresExtraction_task4_function(filteredTestSet);

% Prediction using pre-trained model
predictedLabelsArray = trainedModel.predictFcn(testFeatureTable); 


%% Voting system (1) based on the mode, such that each sample is assigned the most frequent label among the 10 mentioned
windowsPerSample = 10;

function finalPredictions = voting_system_task4(predictions, numWindow)
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
predictedPerSample = voting_system_task4(predictedLabelsArray, windowsPerSample)';

% Update the prediction table with valve faults
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 1)) = 1; % SV1
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 2)) = 2; % SV2
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 3)) = 3; % SV3
predictionsTable.Predictions(filteredTestSet.ID(predictedPerSample == 4)) = 4; % SV4



writetable(predictionsTable, 'predictions.csv');

%% Performance Evaluation

% Loading answers' file to compare true and predicted labels
answers = "./answer.csv";
answers = readtable(answers, 'VariableNamingRule', 'preserve');
trueLabels = answers.task4; 
predictedLabels = predictionsTable.Predictions;

% Accuracy calculation
numCorrect = sum(predictedLabels == trueLabels, 'omitnan');
accuracy = numCorrect / numel(trueLabels) * 100;
disp(['Model Accuracy: ', num2str(accuracy), '%']);

% Confusion Matrix
classLabels = {'Other', 'SV1', 'SV2', 'SV3', 'SV4'};
C = confusionmat(trueLabels, predictedLabels);
figure;
subplot(1,2,1);
confusionchart(C, classLabels);
sgtitle('Testing - Task 4', 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 20);
title(['Total Accuracy Task 4 pipeline: ', num2str(accuracy), '%']);

saveas(gcf, './confusion_matrix.png');