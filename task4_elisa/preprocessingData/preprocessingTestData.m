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


%% Filter Only Bubble Anomalies

% Load prediction file of task 2
predictionsPath = '../../task2_3/predictions.csv';
predictions = readmatrix(predictionsPath);

% Extract the row containing the predicted labels (0 = normal, 1 = unknown
% anomaly, 2 = bubble contamination, 3 = valve fault)
labels = predictions(:, 1);

% Identify indexes
bubbles_indices = find(labels == 2);
normal_indices = find(labels == 0);
unknown_anomalies_indices = find(labels == 1);
valve_faults_indices = find(labels == 3);

% Create a table with only the valve faults cases, keeping the ID
filteredTestSet = testSet(valve_faults_indices, :);

disp(['Number of valve faults cases: ', num2str(height(filteredTestSet))]);


%% Creating the table for predictions

% Let's create a table initially with all NaN values
predictionsTable = table(NaN(numel(cases), 1), 'VariableNames', {'Predictions'});

% We assign 0 to normal elements, unknown anomalies and bubble contamination (i.e. those not present in filteredTestSet)
predictionsTable.Predictions(normal_indices) = 0;
predictionsTable.Predictions(unknown_anomalies_indices) = 0;
predictionsTable.Predictions(bubbles_indices) = 0;