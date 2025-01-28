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

%***Tabella che assegan ad ogni case i suoi rispettivi labels per i vari tasks
size = [numel(datacontainer), 2];
varTypes= {'cell', 'double'};
varNames ={'Case', 'Task2'};
trainingSet = table('Size', size, 'VariableTypes', varTypes, 'VariableNames', varNames);
trainingSet(:, 'Case') = datacontainer;

%% Annotations

% For task2 2 is assigned for anomalies caused by bubbles ("Anomaly"), 3 for solenoid valve failures ("Fault") and 0 for
% normal cases ("Normal")
labels_types = cell(numel(labelsTable.Condition), 1)
for i= 1:numel(labelsTable.Condition)
    if strcmp(labelsTable.Condition(i, 1), "Normal")
        labels_types{i}= 0;
    elseif strcmp(labelsTable.Condition(i,1), "Fault") 
        labels_types{i}= 3;
    else 
        labels_types{i} = 2;
    end
end

trainingSet(:,'Task2') = labels_types;

