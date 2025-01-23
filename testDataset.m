%% Caricamento Dataset di Test

%***Salvataggio percorso dataset di test
TestData = "dataset/test/data/";

%***Leggo i vari case contenuti nel percorso TestDataset e li salvo
%tutti in un array di celle (container). Dove ogni file .csv viene salvato in una
%distinta cella, quindi avrò tante celle quanti sono i file.
cases = dir(TestData + "*.csv");
testDataContainer = cell(numel(cases), 1);

for k = 1:numel(cases)
    casepath = TestData + string(cases(k).name);
    testDataContainer{k} = readtable(casepath);
end

%% Costruzione Dataset di Test Strutturato

%***Tabella che assegna ad ogni case un Task vuoto o predefinito
sizeTest = [numel(testDataContainer), 6];
varTypesTest = {'cell', 'double', 'double', 'double', 'double', 'double'};
varNamesTest = {'Case', 'Task1', 'Task2', 'Task3', 'Task4', 'Task5'};
testData = table('Size', sizeTest, 'VariableTypes', varTypesTest, 'VariableNames', varNamesTest);

% Assegna i dati del test set alla colonna "Case"
testData.Case = testDataContainer;

% Imposta le colonne Task a valori predefiniti
% Task1 = 0 (placeholder, senza etichette)
testData.Task1 = zeros(numel(testDataContainer), 1); % Placeholder
testData.Task2 = zeros(numel(testDataContainer), 1); % Placeholder
testData.Task3 = zeros(numel(testDataContainer), 1); % Placeholder
testData.Task4 = zeros(numel(testDataContainer), 1); % Placeholder
testData.Task5 = zeros(numel(testDataContainer), 1); % Placeholder;

%% Verifica del Dataset
disp(testData);