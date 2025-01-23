% Training Dataset paths
LabelDataset = "C:\Users\Micol\Documents\MATLAB\PHM_Asia_Pacific_Progetto_C1\dataset\train\labels.xlsx";
TrainingDataset = "C:\Users\Micol\Documents\MATLAB\PHM_Asia_Pacific_Progetto_C1\dataset\train\data\";

% Loading the dataset with labels
labelsTable = readtable(LabelDataset);

%Rename column names interpreted as invalid 
labelsTable = renamevars(labelsTable, {'Var1','Var2','Var3'}, {'Case', 'Spacecraft', 'Condition'});

% The various cases contained in the TrainingDataset path are read and saved
% all in a cell array(container), where each .csv file is saved in a
% distinct cell, so there will be as many cells as there are files.
cases = dir(TrainingDataset + "*.csv");
datacontainer = cell(numel(cases), 1);

for k = 1:numel(cases)
    casepath = TrainingDataset + string(cases(k).name);
    datacontainer{k} =readtable(casepath);

end

%% Dataset Construction Structured according to the Challenge Specifications

% Table that assigns to each case its respective labels for task 1
size = [numel(datacontainer), 2];
varTypes= {'cell', 'double'};
varNames ={'Case', 'Task1'};
trainingSet = table('Size', size, 'VariableTypes', varTypes, 'VariableNames', varNames);
trainingSet(:, 'Case') = datacontainer;

%% Annotations

% For task 1 the values ​​must be set to 0, if the case operates in
% normal condition and 1 if the case operates in fault condition or
% unknown anomaly
trainingSet(:, 'Task1') = num2cell(~strcmp(labelsTable.Condition, "Normal"));        


 

        
