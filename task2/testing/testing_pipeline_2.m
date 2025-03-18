% Loading of the test dataset composed of anomalies, obtained by filtering the results obtained by task 1
load("../preprocessingData/filteredTestSet.mat", "filteredTestSet"); 
disp( [newline '__Task2__']);
disp(['Number of samples in the test set: ', num2str(height(filteredTestSet))]);

% loading of the table with predictions
load("../preprocessingData/predictionsTable.mat", "predictionsTable");

% Loading of feature extraction functions respectively for OCSVM and binary classifier training datasets
addpath('../binaryClassification/');
import featuresExtractionFunction_binary.*
addpath('../OC_SVM/');
import featuresExtractionFunction_SVM.*

% Loading pre-trained models
load('../binaryClassification/trainedModel_binary.mat', 'trainedModel_binary');
load('../OC_SVM/Mdl_1.mat', 'Mdl');


%% Known-Unknown Anomalies Classification (OC-SVM)

% Features Extraction
[testFeatureTable, x1] = featuresExtractionFunction_SVM(filteredTestSet);

% Anomalies Prediction (0 = known, 1 = unknown)
[tf_test, scores_test] = isanomaly(Mdl, testFeatureTable);


%% Voting system to aggregate predictions. I have 10 predictions per sample, I take the samples in blocks of 10 predictions and
%% if at least one of these is 1, then the sample is an unknown anomaly, otherwise known

num_windows = 10; 
num_samples = height(filteredTestSet);

% array for aggregate predictions
final_labelsOCSVM = zeros(num_samples, 1);

% We iterate for each sample
for i = 1:num_samples
    start_idx = (i - 1) * num_windows + 1;  % Start of block of 10
    end_idx = start_idx + num_windows - 1;  % End of block
    
    % If at least one window is 1, we mark the sample as 1
    if any(tf_test(start_idx:end_idx) == 1)
        final_labelsOCSVM(i) = 1;
    else
        final_labelsOCSVM(i) = 0;
    end
end

filteredTestSet.OCSVM_Prediction = final_labelsOCSVM;

% Update prediction table: unknown anomalies = 1
predictionsTable.Predictions(filteredTestSet.ID(final_labelsOCSVM == 1)) = 1;


%% Removing unknown anomalies from the test dataset, to have a test dataset composed of only known anomalies for the binary classifier

% Select only rows that have been classified as a known anomaly (0)
testSet_KnownAnomalies = filteredTestSet(final_labelsOCSVM == 0, :);

disp(['Number of samples predicted as known anomaly by OCSVM: ', num2str(height(testSet_KnownAnomalies))]);
disp(['Number of samples predicted as unknown anomaly by OCSVM: ', num2str(23 - height(testSet_KnownAnomalies))]);

% Check if there are still samples available for classification
if isempty(testSet_KnownAnomalies)
    disp("No known anomalies identified for classification.");
    return;
end

testSet_KnownAnomalies.OCSVM_Prediction = [];


%% Classification of the two known anomalies: bubble contamination and valve fault

% Feature Extraction
[testFeatureTable2, x1] = featuresExtractionFunction_binary(testSet_KnownAnomalies);

% Prediction using pre-trained model
predictedLabelsArray = trainedModel_binary.predictFcn(testFeatureTable2); 


%% Voting system (1) based on the mode, such that each sample is assigned the most frequent label among the 10 mentioned
windowsPerSample = 10;

function predictedPerSample = aggregate_predictions_by_mode(predictedLabels, windowsPerSample)
    % Function to aggregate predictions for each sample using the mode
    %
    % INPUT:
    % - predictedLabels: array of predictions for all windows
    % - windowsPerSample: number of windows for each sample
    %
    % OUTPUT:
    % - predictedPerSample: array of aggregated predictions for each sample

    % Calculate the total number of samples
    numSamples = numel(predictedLabels) / windowsPerSample;
    
    % Initialize an array for the aggregated predictions
    predictedPerSample = zeros(numSamples, 1);

    % Aggregate predictions for each sample
    for i = 1:numSamples
        % Extract predictions for the current sample
        startIdx = (i - 1) * windowsPerSample + 1;  % Start index
        endIdx = i * windowsPerSample;             % End index
        samplePredictions = predictedLabels(startIdx:endIdx);

        % Calculate the mode of the predictions
        predictedPerSample(i) = mode(samplePredictions);
    end
end

% Aggregates predictions for sample
predictedPerSample = aggregate_predictions_by_mode(predictedLabelsArray, windowsPerSample)';

count_valve = length(predictedPerSample(predictedPerSample == 1));   
count_bubble = length(predictedPerSample(predictedPerSample == 2));
 
disp(['Samples classified as valve fault by binary classifier (using mode): ', num2str(count_valve)]);
disp(['Samples classified as bubble contamination by binary classifier (using mode): ' , num2str(count_bubble)]);


%% threshold-based voting system (2)

function predictedPerSample = aggregate_predictions_with_threshold(predictedLabels, windowsPerSample, threshold)
    % Function to aggregate predictions for each sample using a threshold-based approach
    %
    % INPUT:
    % - predictedLabels: array of predictions for all windows
    % - windowsPerSample: number of windows for each sample
    % - threshold: minimum count of class 2 (bubble contamination) to classify as 2
    %
    % OUTPUT:
    % - predictedPerSample: array of aggregated predictions for each sample

    % Calculate the total number of samples
    numSamples = numel(predictedLabels) / windowsPerSample;
    
    % Initialize an array for the aggregated predictions (default: class 1)
    predictedPerSample = ones(numSamples, 1); % Default to 1 (valve fault)

    % Aggregate predictions for each sample
    for i = 1:numSamples
        % Extract predictions for the current sample
        startIdx = (i - 1) * windowsPerSample + 1;  % Start index
        endIdx = i * windowsPerSample;             % End index
        samplePredictions = predictedLabels(startIdx:endIdx);

        % Count occurrences of class 2 (bubble contamination)
        count_class2 = sum(samplePredictions == 2);

        % If class 2 appears at least `threshold` times, classify as 2
        if count_class2 >= threshold
            predictedPerSample(i) = 2;
        end
    end
end

% Threshold definition: minimum number of windows that must be class 2
threshold = 2; 

% Aggregation with threshold-based voting system
predictedPerSample = aggregate_predictions_with_threshold(predictedLabelsArray, windowsPerSample, threshold)';

count_valve = sum(predictedPerSample == 1);
count_bubble = sum(predictedPerSample == 2);

disp(['Samples classified as valve fault by binary classifier (using threshold): ', num2str(count_valve)]);
disp(['Samples classified as bubble contamination by binary classifier (using threshold): ' , num2str(count_bubble)]);

% Update the prediction table with known anomalies
predictionsTable.Predictions(testSet_KnownAnomalies.ID(predictedPerSample == 2)) = 2; % Bubble
predictionsTable.Predictions(testSet_KnownAnomalies.ID(predictedPerSample == 1)) = 3; % Valve

writetable(predictionsTable, 'predictions.csv');

%% Performance Evaluation

% Loading answers' file to compare true and predicted labels
answers = "./answer.csv";
answers = readtable(answers, 'VariableNamingRule', 'preserve');
trueLabels = answers.task2; 
predictedLabels = predictionsTable.Predictions;

% Accuracy calculation
numCorrect = sum(predictedLabels == trueLabels, 'omitnan');
accuracy = numCorrect / numel(trueLabels) * 100;
disp(['Model Accuracy: ', num2str(accuracy), '%']);

% Confusion Matrix

classLabels2 = {'Normal', 'Unknown', 'Bubble Anomaly', 'Valve'};
C2 = confusionmat(trueLabels, predictedLabels);
figure;
subplot(1,2,1);
confusionchart(C2, classLabels2);
sgtitle('Testing - Task 2', 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 20);
title(['Total Accuracy Task 2 pipeline: ', num2str(accuracy), '%']);

saveas(gcf, './confusion_matrix.png');

