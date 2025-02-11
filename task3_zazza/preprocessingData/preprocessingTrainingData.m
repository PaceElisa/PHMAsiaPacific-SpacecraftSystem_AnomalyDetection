% Definition of training data and labels path
dataFolder = "../../dataset/train/data/";
labelsFile = '../../dataset/train/labels.xlsx';

% Read all csv files and saves them into 'data' array
files = dir(fullfile(dataFolder, '*.csv'));
data = cell(1, numel(files));
for i = 1:numel(files)
    filePath = fullfile(dataFolder, files(i).name);
    data{i} = readtable(filePath);
end

% Read labels file and rename vars as "Case", "Spacecraft", "Condition", and assigns to labels the Condition values
labelsTable = readtable(labelsFile);
labelsTable = renamevars(labelsTable,["Var1","Var2","Var3"],["Case","Spacecraft","Condition"]);

% Creates a table with two columns, the first with the data, and the second with labels (0,1,2)
trainingData = cell(numel(data),2);
for i = 1:numel(data)
    trainingData{i, 1} = data{i};
    
    if labelsTable{i, "Condition"} == "Normal" || (labelsTable{i,"BP1"}=="No" && labelsTable{i,"BP2"}=="No" && labelsTable{i,"BP3"}=="No" && labelsTable{i,"BP4"}=="No" && labelsTable{i,"BP5"}=="No" && labelsTable{i,"BP6"}=="No" && labelsTable{i,"BP7"}=="No" && labelsTable{i,"BV1"}=="No")
        trainingData{i, 2} = 'toDrop';
    elseif labelsTable{i,"BP1"} == "Yes"
        trainingData{i,2} = 1;
    elseif labelsTable{i,"BP2"} == "Yes"
        trainingData{i,2} = 2;
    elseif labelsTable{i,"BP3"} == "Yes"
        trainingData{i,2} = 3;
    elseif labelsTable{i,"BP4"} == "Yes"
        trainingData{i,2} = 4;
    elseif labelsTable{i,"BP5"} == "Yes"
        trainingData{i,2} = 5;
    elseif labelsTable{i,"BP6"} == "Yes"
        trainingData{i,2} = 6;
    elseif labelsTable{i,"BP7"} == "Yes"
        trainingData{i,2} = 7;
    elseif labelsTable{i,"BV1"} == "Yes"
        trainingData{i,2} = 8;
    end  

end
        
% Find indices of rows to keep (i.e., where the label is not 'toDrop')
validRows = ~strcmp(trainingData(:,2), 'toDrop');

% Apply filtering
Cases = trainingData(validRows,1);
Labels = trainingData(validRows,2);

% Convert labels to numeric
Labels = cell2mat(Labels);

% Create table
trainingTable = table(Cases, Labels, 'VariableNames', {'Case', 'Label'});

