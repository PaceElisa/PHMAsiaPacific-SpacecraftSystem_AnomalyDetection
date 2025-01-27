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