% Function to aggregate predictions by mode
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
