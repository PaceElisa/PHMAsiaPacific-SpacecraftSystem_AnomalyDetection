% Caricamento del dataset di test composto da sole anomalie, ottenuto
% filtrando i risultati ottenuti dal task 1
load("./preprocessingData/filteredTestSet.mat", "filteredTestSet");  

% Caricamento delle funzioni di estrazione delle features rispettivamente
% per i dataset di training della OCSVM e del classificatore binario 
addpath('./BinaryClassification/');
import featuresExtractionFunction_binary.*
addpath('./OC_SVM/');
import featuresExtractionFunction_SVM.*

% Caricamento dei modelli preaddestrati 
load('./BinaryClassification/trainedModel_binary.mat', 'trainedModel_binary');
load('./OC_SVM/Mdl.mat', 'Mdl')

%% Classificazione anomalie note-sconosciute (OC-SVM)

% Estrazione delle features
[testFeatureTable, x1] = featuresExtractionFunction_SVM(filteredTestSet);

% Predizione delle anomalie (0 = nota, 1 = sconosciuta)
[tf_test, scores_test] = isanomaly(Mdl, testFeatureTable);

disp(['Numero di campioni nel test set originale: ', num2str(height(filteredTestSet))]);

%% Sistema di voting per aggregare le predizioni. Ho 10 predizioni per campione, prendo i campioni in blocchi di 10 predizioni e 
%% se tra queste almeno una è 1, allora il campione è un'anomalia sconosciuta, altrimenti nota

num_windows = 10; % Finestratura della frame policy
num_samples = height(filteredTestSet); % Numero di campioni originali

% Creiamo un array per le predizioni aggregate
final_labelsOCSVM = zeros(num_samples, 1);

% Iteriamo per ogni campione
for i = 1:num_samples
    start_idx = (i - 1) * num_windows + 1;  % Inizio del blocco da 10
    end_idx = start_idx + num_windows - 1;  % Fine del blocco da 10
    
    % Se almeno una finestra è 1, segniamo il campione come 1
    if any(tf_test(start_idx:end_idx) == 1)
        final_labelsOCSVM(i) = 1;
    else
        final_labelsOCSVM(i) = 0;
    end
end

% Ora possiamo assegnare le predizioni finali alla tabella
filteredTestSet.OCSVM_Prediction = final_labelsOCSVM;

%% Rimozione delle anomalie sconosciute dal dataset di test, per avere un dataset di test composto
%% da sole anomalie note per il classificatore binario

% Seleziona solo le righe che sono state classificate come anomalia nota (0)
testSet_KnownAnomalies = filteredTestSet(final_labelsOCSVM == 0, :);

disp(['Numero di campioni predetti come anomalia nota dalla OCSVM: ', num2str(height(testSet_KnownAnomalies))]);
disp(['Numero di campioni predetti come anomalia ignota dalla OCSVM: ', num2str(34 - height(testSet_KnownAnomalies))]);

% Controllo se ci sono ancora campioni disponibili per la classificazione
if isempty(testSet_KnownAnomalies)
    disp("Nessuna anomalia nota identificata per la classificazione.");
    return;
end

testSet_KnownAnomalies.OCSVM_Prediction = [];

%% Classificazione delle due anomalie note: contaminazione da bolle e guasto alle valvole

% Estrazione delle features
[testFeatureTable2, x1] = featuresExtractionFunction_binary(testSet_KnownAnomalies);

% Predizione utilizzando il modello preaddestrato
predictedLabelsArray = trainedModel_binary.predictFcn(testFeatureTable2); 

%% Sistema di voting basato sulla moda, tale che viene assegnata ad ogni campione l'etichetta più frequente tra le 10 predette
windowsPerSample = 10;

function predictedPerSample = aggregate_predictions_by_mode(predictedLabels, windowsPerSample)
    % Function to aggregate predictions for each sample using the mode
    %
    % INPUT:
    % - predictedLabels: array of predictions for all windows
    % - windowsPerSample: number of windows for each sample
    %
    % OUTPUT:
    % - predictedPerSample: array of aggregated predictions for each sample

    % Calculate the total number of samples
    numSamples = numel(predictedLabels) / windowsPerSample;
    
    % Initialize an array for the aggregated predictions
    predictedPerSample = zeros(numSamples, 1);

    % Aggregate predictions for each sample
    for i = 1:numSamples
        % Extract predictions for the current sample
        startIdx = (i - 1) * windowsPerSample + 1;  % Start index
        endIdx = i * windowsPerSample;             % End index
        samplePredictions = predictedLabels(startIdx:endIdx);

        % Calculate the mode of the predictions
        predictedPerSample(i) = mode(samplePredictions);
    end
end

% Aggregates predictions for sample
predictedPerSample = aggregate_predictions_by_mode(predictedLabelsArray, windowsPerSample)';


count_valve = length(predictedPerSample(predictedPerSample == 1));   
count_bubble = length(predictedPerSample(predictedPerSample == 2));
 
disp(['Campioni classificati come guasto alle valvole dal classificatore binario: ', num2str(count_valve)]);
disp(['Campioni classificati come contaminazione da bolle dal classificatore binario: ' , num2str(count_bubble)]);

