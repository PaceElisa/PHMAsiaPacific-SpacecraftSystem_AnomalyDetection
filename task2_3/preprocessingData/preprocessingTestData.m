% Test dataset path
TestData = '../../dataset/test/data/';

% Reading CSV files in the test dataset
cases = dir(TestData + "*.csv");
testDataContainer = cell(numel(cases), 1);
caseIDs = (1:numel(cases))';  % Creates an array of unique IDs

for k = 1:numel(cases)
    casepath = TestData + string(cases(k).name);
    testDataContainer{k} = readtable(casepath);
end


%% Test Set Construction

% Let's create a table with a unique ID for each case
sizeTest = [numel(testDataContainer), 3]; 
varTypesTest = {'double', 'cell', 'double'};
varNamesTest = {'ID', 'Case', 'Label'};
testSet = table('Size', sizeTest, 'VariableTypes', varTypesTest, 'VariableNames', varNamesTest);

% Calculation of the number of samples of the original test dataset
disp(['Number of samples in the test dataset: ', num2str(numel(testDataContainer))]);

% Assign the data
testSet.ID = caseIDs;  
testSet.Case = testDataContainer;
testSet.Label = zeros(numel(testDataContainer), 1); % Placeholder 


%% Filter Only Anomalies

% Load prediction file of task 1
predictionsPath = '../../task1_last/testing/predictions_per_sample_task1_treshold.csv';
predictions = readmatrix(predictionsPath);

% Extract the row containing the predicted labels (0 = normal, 1 = anomaly)
labels = predictions(1, :);

% Identify indexes
anomaly_indices = find(labels == 1);
normal_indices = find(labels == 0);

% Create a table with only the anomalous cases, keeping the ID
filteredTestSet = testSet(anomaly_indices, :);

disp(['Number of anomalous test cases: ', num2str(height(filteredTestSet))]);


%% Creating the table for predictions

% Let's create a table initially with all NaN values
predictionsTable = table(NaN(numel(cases), 1), 'VariableNames', {'Predictions'});

% We assign 0 to normal elements (i.e. those not present in filteredTestSet)
predictionsTable.Predictions(normal_indices) = 0;

