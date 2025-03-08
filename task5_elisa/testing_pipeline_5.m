% Loading of the test dataset composed of valve faults, obtained by filtering
% the results obtained by task 2
load("./preprocessingData/filteredTestSet5.mat", "filteredTestSet5");  
disp(['Number of samples in the test set: ', num2str(height(filteredTestSet5))]);

% loading of the table with predictions
load("./preprocessingData/predictionsTable5.mat", "predictionsTable5");

% Loading of feature extraction function 
addpath('./featuresExtraction/');
import featuresExtraction_task5_function.*

% Loading pre-trained model
load('./training/trainedModel.mat', 'trainedModel');


%% Valve Faults Classification

% Features Extraction
[testFeatureTable, x1] = featuresExtraction_task5_function(filteredTestSet5);

% Prediction using pre-trained model
predictedLabelsArray = trainedModel.predictFcn(testFeatureTable); 


%% Voting system (1) based on the median, such that each sample is assigned the median value among the 10 mentioned
windowsPerSample = 10;

function finalPredictions = voting_system_task5(predictions, numWindow)
% VOTING_SYSTEM_TASK5 - Aggrega le predizioni per il Task 5 utilizzando il
% metodo della mediana
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
        finalPredictions(i) = median(samplePredictions);
    end
end

% Aggregates predictions for sample
predictedPerSample = voting_system_task5(predictedLabelsArray, windowsPerSample)';

% Update the prediction table with valve faults opening ratio %
predictionsTable5.Predictions(filteredTestSet5.ID) = predictedPerSample;




writetable(predictionsTable5, 'predictions5.csv');

%% Performance Evaluation of Test Dataset Samples

% Loading answers' file to compare true and predicted labels
answers = "./answer.csv";
answers = readtable(answers, 'VariableNamingRule', 'preserve');
%trueLabelsAll = answers.task5;
trueLabels = table2array(answers(filteredTestSet5.ID, "task5")); % this way I can compare only valve fault cases
%predictedLabelsAll = predictionsTable5.Predictions;
predictedLabels = table2array(predictionsTable5(filteredTestSet5.ID, "Predictions"));


% Metric calculation for regression assessment
RMSE = sqrt(mean((trueLabels - predictedLabels).^2));
MAE = mean(abs(trueLabels - predictedLabels));
SSres = sum((trueLabels - predictedLabels).^2);
SStot = sum((trueLabels - mean(trueLabels)).^2);
R2 = 1 - (SSres / SStot);

% Rendering Scatter plot for samples
figure;
samples =1:length(predictedLabels);
scatter(samples, predictedLabels, 50,'r', 'filled'); 
hold on;
scatter(samples, trueLabels, 50, 'g', 'filled');
title(sprintf('Comparison between Predicted and True values\nRMSE: %.4f, MAE: %.4f, R²: %.4f', RMSE, MAE, R2));
xlabel('True');
ylabel('Predicted');
legend('Predicted', 'True', 'Location', 'best');
grid on;
fig_name = 'scatter_plot_task5_sample';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, [fig_name, '.png']);

% Rendering Scatter plot by values order
%{
figure;
scatter(trueLabels, predictedLabels, 50,'r', 'filled'); 
hold on;
scatter(trueLabels, trueLabels, 50, 'g', 'filled');
title(sprintf('Comparison between Predicted and True values\nRMSE: %.4f, MAE: %.4f, R²: %.4f', RMSE, MAE, R2));
xlabel('True');
ylabel('Predicted');
legend('Predicted', 'True', 'Location', 'best');
grid on;
fig_name = 'scatter_plot_task5_1';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, [fig_name, '.png']);
%}

%% Performance Evaluation of  All Test Dataset

% Loading answers' file to compare true and predicted labels
answers = "./answer.csv";
answers = readtable(answers, 'VariableNamingRule', 'preserve');
trueLabelsAll = answers.task5;
predictedLabelsAll = predictionsTable5.Predictions;


% Metric calculation for regression assessment
RMSE = sqrt(mean((trueLabelsAll - predictedLabelsAll).^2));
MAE = mean(abs(trueLabelsAll - predictedLabelsAll));
SSres = sum((trueLabelsAll - predictedLabelsAll).^2);
SStot = sum((trueLabelsAll - mean(trueLabelsAll)).^2);
R2 = 1 - (SSres / SStot);

% Rendering Scatter plot for samples
figure;
samples =1:length(predictedLabelsAll);
scatter(samples, predictedLabelsAll, 50,'r', 'filled'); 
hold on;
scatter(samples, trueLabelsAll, 50, 'g', 'filled');
title(sprintf('Comparison between Predicted and True values\nRMSE: %.4f, MAE: %.4f, R²: %.4f', RMSE, MAE, R2));
xlabel('True');
ylabel('Predicted');
legend('Predicted', 'True', 'Location', 'best');
grid on;
fig_name = 'scatter_plot_task5_all';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, [fig_name, '.png']);
