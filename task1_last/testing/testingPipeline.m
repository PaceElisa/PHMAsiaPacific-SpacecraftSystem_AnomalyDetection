% Testing pipeline to evaluate performance on the original test set

addpath('../hyperparameterTuning/');
addpath('../hyperparameterTuning/Experiment_Task1/');
addpath('../hyperparameterTuning/Experiment_Task1/Results/Experiment1_Result1_20250123T151532/Snapshot/');

% Preprocessing training and test datasets
run("../preprocessingData/trainingData.m")
run("../preprocessingData/testData.m")

% Loading functions for feature extraction and voting system
addpath('../featuresExtraction/');
import diagnosticFeaturesExtraction_task1.*
import aggregate_predictions_by_mode.*

% Loading pre-trained and tuned model
load('../hyperparameterTuning/optimizedModel1.mat');

% Loading answers' file to compare true and predicted labels
answers = '../testing/answer.csv';
answers = readtable(answers, 'VariableNamingRule', 'preserve');

%% Frame Policy = 128ms -> number of windows for sample = 10 (1200ms/128ms)
windowsPerSample = 10;

% Features extraction from test data
[testFeatureTable1, x1] = diagnosticFeaturesExtraction_task1(testSet);

% Making predictions on test set using pre-trained model
predictedLabelsArray = optimizedModel1.predictFcn(testFeatureTable1); 

% Number of predictions
numPredictedLabels = numel(predictedLabelsArray);
disp( [newline '__Task1__']);
disp(['Number of predicted labels: ', num2str(numPredictedLabels/windowsPerSample)]);

% saves predictions on a csv file
%writetable(table(predictedLabelsArray), '../testing/predictions_test_set.csv');

%% Voting system using moda (1)

%{
% Aggregates predictions for sample
predictedPerSample = aggregate_predictions_by_mode(predictedLabelsArray, windowsPerSample)';

% Prints number of final predictions
finalPredictionsNumber = numel(predictedPerSample);  % Numero di predizioni
disp(['Number of final predicted labels: ', num2str(finalPredictionsNumber)]);

% Saves results on a csv file
writetable(table(predictedPerSample), '../testing/predictions_per_sample_task1_moda.csv');

count_normal = length(predictedPerSample(predictedPerSample == 0));   
count_abnormal = length(predictedPerSample(predictedPerSample == 1));
 
disp(['Data classified as normal (class 0): ', num2str(count_normal)]);
disp(['Data classified as abnormal (class 1): ' , num2str(count_abnormal)]);

%}

%% Voting System using threshold (2)
threshold = int32(windowsPerSample*7/10)+1;
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

% Saves results on a csv file
writetable(table(prediction), '../testing/predictions_per_sample_task1_treshold.csv');

count_normal = length(prediction(prediction == 0));   
count_abnormal = length(prediction(prediction == 1));
 
fprintf('Data classified as normal (class 0): %d \n', count_normal);
fprintf('Data classified as abnormal (class 1): %d \n', count_abnormal);

%% Performance evaluation for voting system (1)

%{
correct_answer_task1 = answers.task1';
rightPredic1 = correct_answer_task1 == predictedPerSample;

% Calculates accuracy
accuracy = (sum(rightPredic1) / numel(correct_answer_task1)*100);

% Displays accuracy
disp(['Accuracy: ', num2str(accuracy), '%']);

% Rendering Confusion Matrix
classLabels = {'Normal', 'Abnormal'};
C = confusionmat(correct_answer_task1, predictedPerSample);
figure;
confusionchart(C, classLabels);
title(['Total Accuracy Task 1: ', num2str(accuracy), ' %']);
fig_name = '../testing/figures/confusionmatrix1_task1';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, [fig_name, '.png']);

% Add id to predictions and transpose prediction1
predictedPerSample = [answers.ID predictedPerSample'];

%}

%% Performance evaluation for voting system (2)

correct_answer_task1 = answers.task1';
rightPredic2 = correct_answer_task1 == prediction;

% Calculates accuracy
accuracy = (sum(rightPredic2) / numel(correct_answer_task1)*100);

% Displays accuracy
disp(['Accuracy: ', num2str(accuracy), '%']);

% Rendering Confusion Matrix
classLabels = {'Normal', 'Abnormal'};
C = confusionmat(correct_answer_task1, prediction);
figure;
confusionchart(C, classLabels);
title(['Total Accuracy Task 1: ', num2str(accuracy), ' %']);
fig_name = '../testing/figures/confusionmatrix2_task1';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, [fig_name, '.png']);

% Add id to predictions and transpose prediction1
prediction = [answers.ID prediction'];
