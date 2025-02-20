% Testing pipeline to evaluate performance on the original test set

% Preprocessing training and test datasets
run("../preprocessingData/trainingData.m")
run("../preprocessingData/testData.m")

% Loading functions for feature extraction and voting system
addpath('../featuresExtraction/');
import diagnosticFeaturesExtraction_task1.*

% Loading pre-trained model
load('../training/trained_BaggedTrees_2.mat');

% Loading answers' file to compare true and predicted labels
answers = '../testing/answer.csv';
answers = readtable(answers, 'VariableNamingRule', 'preserve');

% Frame Policy = 0.128ms -> number of windows for sample = 10 (1200ms/0.128ms)
windowsPerSample = 10;

% Features extraction from test data
[testFeatureTable1, x1] = diagnosticFeaturesExtraction_task1(testSet);

% Making predictions on test set using pre-trained model
predictedLabelsArray = trained_BaggedTrees_2.predictFcn(testFeatureTable1); 

% Number of predictions
numPredictedLabels = numel(predictedLabelsArray); 
disp(['Number of predicted labels: ', num2str(numPredictedLabels)]);

% Voting System using threshold
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


% Performance evaluation
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
fig_name = '../testing/figures/confusionmatrix_BaggedTrees_2_task1';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, [fig_name, '.png']);

% Add id to predictions and transpose prediction1
prediction = [answers.ID prediction'];