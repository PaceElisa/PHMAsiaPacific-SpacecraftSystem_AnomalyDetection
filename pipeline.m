% Preprocessing training and test data
run("C:\Users\Micol\Documents\MATLAB\PHM_Asia_Pacific_Progetto_C1\trainigDataset.m")
run("C:\Users\Micol\Documents\MATLAB\PHM_Asia_Pacific_Progetto_C1\testDataset.m")

% Features extraction
addpath('task1/');
import generate_features_task1.*

%% task 1, dati normali e anormali

% **** Generazione delle feature dei dati di test del task 1 ****
[testFeatureTable1, x1] = generate_features_task1(testData);

% Carica il modello addestrato
load('bestModel.mat');
% Check the structure of trainedModel_task1
whos bestModel

% Predizioni sulle feature del dataset di test
predictedLabelsArray = bestModel.predictFcn(testFeatureTable1); % Salva le predizioni in un array

% Visualizza o salva i risultati
disp(predictedLabelsArray);  % Visualizza le predizioni

% Stampa il numero di etichette predette
numPredictedLabels = numel(predictedLabelsArray);  % Numero di predizioni
disp(['Numero di etichette predette: ', num2str(numPredictedLabels)]);

% Salva le predizioni iniziali su un file CSV
writetable(table(predictedLabelsArray), 'predictions_test_set.csv');

% Definizione della funzione per aggregare le predizioni
function predictedPerSample = aggregate_predictions_by_mode(predictedLabels, windowsPerSample)
    % Funzione per aggregare le predizioni per campione usando la moda
    %
    % INPUT:
    % - predictedLabels: array di predizioni per tutte le finestre
    % - windowsPerSample: numero di finestre per ciascun campione
    %
    % OUTPUT:
    % - predictedPerSample: array di predizioni aggregate per ciascun campione

    % Calcola il numero totale di campioni
    numSamples = numel(predictedLabels) / windowsPerSample;
    
    % Inizializza un array per le predizioni aggregate
    predictedPerSample = zeros(numSamples, 1);

    % Aggrega le predizioni per ogni campione
    for i = 1:numSamples
        % Estrai le predizioni per il campione corrente
        startIdx = (i - 1) * windowsPerSample + 1;  % Indice iniziale
        endIdx = i * windowsPerSample;             % Indice finale
        samplePredictions = predictedLabels(startIdx:endIdx);

        % Calcola la moda delle predizioni
        predictedPerSample(i) = mode(samplePredictions);
    end
end

% Numero di finestre per campione
windowsPerSample = 10;

% Aggrega le predizioni per campione
predictedPerSample = aggregate_predictions_by_mode(predictedLabelsArray, windowsPerSample);

% Stampa il numero di predizioni finale
finalPredictionsNumber = numel(predictedPerSample);  % Numero di predizioni
disp(['Numero di etichette finali predette: ', num2str(finalPredictionsNumber)]);

% Visualizza o salva le predizioni finali
disp('Predizioni per campione:');
disp(predictedPerSample);

% Salva i risultati in un file CSV
writetable(table(predictedPerSample), 'predictions_per_sample.csv');
