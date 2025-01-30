% definition of data and labels path
dataFolder = 'C:\Users\Micol\Documents\MATLAB\PHM_Asia_Pacific_Progetto_C1\dataset\train\data\';
labelsFile = 'C:\Users\Micol\Documents\MATLAB\PHM_Asia_Pacific_Progetto_C1\dataset\train\labels.xlsx';

% read all csv files and saves them into 'data' array
files = dir(fullfile(dataFolder, '*.csv'));
data = cell(1, numel(files));
for i = 1:numel(files)
    filePath = fullfile(dataFolder, files(i).name);
    data{i} = readtable(filePath);
end

% read labels file and rename vars as "Case", "Spacecraft", "Condition",
% and assigns to labels the Condition values
labelsTable = readtable(labelsFile);
labelsTable = renamevars(labelsTable,["Var1","Var2","Var3"],["Case","Spacecraft","Condition"]);

% creates a table with two columns, the first with the data, and the second
% with labels (0,1,2)
trainingData = cell(numel(data),2);
for i = 1:numel(data)
    trainingData{i, 1} = data{i};
    
    if labelsTable{i, "Condition"} == "Normal"
        trainingData{i, 2} = 0;
    elseif labelsTable{i,"SV1"}~=100 || labelsTable{i,"SV2"}~=100 || labelsTable{i,"SV3"}~=100 || labelsTable{i,"SV4"}~=100
        trainingData{i, 2} = 1; % solenoid valve fault
    elseif labelsTable{i,"BP1"}=="Yes" || labelsTable{i,"BP2"}=="Yes" || labelsTable{i,"BP3"}=="Yes" || labelsTable{i,"BP4"}=="Yes" || labelsTable{i,"BP5"}=="Yes" || labelsTable{i,"BP6"}=="Yes" || labelsTable{i,"BP7"}=="Yes" || labelsTable{i,"BV1"}=="Yes"
        trainingData{i, 2} = 2; % bubbles
    else 
        trainingData{i, 2} = 3; % unknown anomalies (0)
    end    
end

% Converts trainingData in a table with two columns: "Case" e "Label"
Case = trainingData(:,1); 
Labels = cell2mat(trainingData(:,2)); % Converte la seconda colonna (Label) in numerico

% Filter only anomalies ( 1 e 2)
anomalyIndices = Labels ~= 0; % finds raws with label != 0
Case = Case(anomalyIndices); 
Labels = Labels(anomalyIndices); 

% training data for binary classification
trainingTable_binary = table(Case, Labels, 'VariableNames', {'Case', 'Label'});

% Converts all labels to 0 = known anomaly (for one class SVM)
Labels_SVM = Labels; 
Labels_SVM(Labels_SVM == 1 | Labels_SVM == 2) = 0; % known anomalies → 0
Labels_SVM(Labels_SVM == 3) = 1; % unknown anomalies → 1

% Training data for OC-SVM
trainingTable_SVM = table(Case, Labels_SVM, 'VariableNames', {'Case', 'Label'});