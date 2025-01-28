% Test dataset path
TestData = "C:\Users\Micol\Documents\MATLAB\PHM_Asia_Pacific_Progetto_C1\dataset\test\data\";

% The various cases contained in the test dataset path are read and saved
% all in a cell array (container), where each .csv file is saved in a
% distinct cell, so there will be as many cells as there are files.
cases = dir(TestData + "*.csv");
testDataContainer = cell(numel(cases), 1);

for k = 1:numel(cases)
    casepath = TestData + string(cases(k).name);
    testDataContainer{k} = readtable(casepath);
end

%% Test Dataset Construction

% Table that assigns an empty or default label to each case
sizeTest = [numel(testDataContainer), 2];
varTypesTest = {'cell', 'double'};
varNamesTest = {'Case', 'Task2'};
testSet = table('Size', sizeTest, 'VariableTypes', varTypesTest, 'VariableNames', varNamesTest);

% Assign test set data to "Case" column
testSet.Case = testDataContainer;

% Sets Task1 column to default values
% Task1 = 0 (placeholder, without labels)
testSet.Task2 = zeros(numel(testDataContainer), 1); % Placeholder
