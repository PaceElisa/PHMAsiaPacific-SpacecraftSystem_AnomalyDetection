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

% Creates a table with two columns, the first with the data, and the second with labels (1,2,3,4)
trainingData = cell(numel(data),2);
for i = 1:numel(data)
    trainingData{i, 1} = data{i};
    
    if labelsTable{i, "Condition"} == "Normal" || labelsTable{i, "Condition"} == "Anomaly" || (labelsTable{i,"SV1"}==100 && labelsTable{i,"SV2"}==100 && labelsTable{i,"SV3"}==100 && labelsTable{i,"SV4"}==100)
        trainingData{i, 2} = 'toDrop';
    elseif labelsTable{i,"SV1"} ~= 100
        trainingData{i,2} = 1;
    elseif labelsTable{i,"SV2"} ~= 100
        trainingData{i,2} = 2;
    elseif labelsTable{i,"SV3"} ~= 100
        trainingData{i,2} = 3;
    elseif labelsTable{i,"SV4"} ~= 100
        trainingData{i,2} = 4;
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

