function [featureTable,outputTable] = diagnosticFeatures(inputData)
%DIAGNOSTICFEATURES recreates results in Diagnostic Feature Designer.
%
% Input:
%  inputData: A table or a cell array of tables/matrices containing the
%  data as those imported into the app.
%
% Output:
%  featureTable: A table containing all features and condition variables.
%  outputTable: A table containing the computation results.
%
% This function computes features:
%  Case_sigstats/Kurtosis
%  Case_sigstats/PeakValue
%  Case_sigstats/SINAD
%  Case_sigstats/SNR
%  Case_sigstats_1/Kurtosis
%  Case_sigstats_1/PeakValue
%  Case_sigstats_1/SINAD
%  Case_sigstats_2/Kurtosis
%  Case_sigstats_2/PeakValue
%  Case_sigstats_3/Kurtosis
%  Case_sigstats_4/Kurtosis
%  Case_sigstats_4/PeakValue
%  Case_sigstats_4/SINAD
%  Case_sigstats_5/Kurtosis
%  Case_sigstats_6/Kurtosis
%
% Frame Policy:
%  Frame name: FRM_1
%  Frame size: 0.128 seconds
%  Frame rate: 0.128 seconds
%
% Organization of the function:
% 1. Compute signals/spectra/features
% 2. Extract computed features into a table
%
% Modify the function to add or remove data processing, feature generation
% or ranking operations.

% Auto-generated by MATLAB on 16-Mar-2025 13:51:25

% Create output ensemble.
outputEnsemble = workspaceEnsemble(inputData,'DataVariables',"Case",'ConditionVariables',"Label");

% Reset the ensemble to read from the beginning of the ensemble.
reset(outputEnsemble);

% Append new frame policy name to DataVariables.
outputEnsemble.DataVariables = [outputEnsemble.DataVariables;"FRM_1"];

% Set SelectedVariables to select variables to read from the ensemble.
outputEnsemble.SelectedVariables = "Case";

% Initialize a cell array to store all the results.
allMembersResult = {};

% Loop through all ensemble members to read and write data.
while hasdata(outputEnsemble)
    % Read one member.
    member = read(outputEnsemble);

    % Read signals.
    Case_full = readMemberData(member,"Case",["TIME","P1","P2","P3","P4","P5","P6","P7"]);

    % Get the frame intervals.
    lowerBound = Case_full.TIME(1);
    upperBound = Case_full.TIME(end);
    fullIntervals = frameintervals([lowerBound upperBound],0.128,0.128,'FrameUnit',"seconds");
    intervals = fullIntervals;

    % Initialize a table to store frame results.
    frames = table;

    % Loop through all frame intervals and compute results.
    for ct = 1:height(intervals)
        % Get all input variables.
        Case = Case_full(Case_full.TIME>=intervals{ct,1}&Case_full.TIME<intervals{ct,2},:);

        % Initialize a table to store results for one frame interval.
        frame = intervals(ct,:);

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P1;
            Kurtosis = kurtosis(inputSignal);
            PeakValue = max(abs(inputSignal));
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);

            % Concatenate signal features.
            featureValues = [Kurtosis,PeakValue,SINAD,SNR];

            % Store computed features in a table.
            featureNames = {'Kurtosis','PeakValue','SINAD','SNR'};
            Case_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,4);
            featureNames = {'Kurtosis','PeakValue','SINAD','SNR'};
            Case_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats},'VariableNames',{'Case_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P2;
            Kurtosis = kurtosis(inputSignal);
            PeakValue = max(abs(inputSignal));
            SINAD = sinad(inputSignal);

            % Concatenate signal features.
            featureValues = [Kurtosis,PeakValue,SINAD];

            % Store computed features in a table.
            featureNames = {'Kurtosis','PeakValue','SINAD'};
            Case_sigstats_1 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'Kurtosis','PeakValue','SINAD'};
            Case_sigstats_1 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_1},'VariableNames',{'Case_sigstats_1'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P3;
            Kurtosis = kurtosis(inputSignal);
            PeakValue = max(abs(inputSignal));

            % Concatenate signal features.
            featureValues = [Kurtosis,PeakValue];

            % Store computed features in a table.
            featureNames = {'Kurtosis','PeakValue'};
            Case_sigstats_2 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'Kurtosis','PeakValue'};
            Case_sigstats_2 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_2},'VariableNames',{'Case_sigstats_2'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P4;
            Kurtosis = kurtosis(inputSignal);

            % Concatenate signal features.
            featureValues = Kurtosis;

            % Store computed features in a table.
            featureNames = {'Kurtosis'};
            Case_sigstats_3 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,1);
            featureNames = {'Kurtosis'};
            Case_sigstats_3 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_3},'VariableNames',{'Case_sigstats_3'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P5;
            Kurtosis = kurtosis(inputSignal);
            PeakValue = max(abs(inputSignal));
            SINAD = sinad(inputSignal);

            % Concatenate signal features.
            featureValues = [Kurtosis,PeakValue,SINAD];

            % Store computed features in a table.
            featureNames = {'Kurtosis','PeakValue','SINAD'};
            Case_sigstats_4 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'Kurtosis','PeakValue','SINAD'};
            Case_sigstats_4 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_4},'VariableNames',{'Case_sigstats_4'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P6;
            Kurtosis = kurtosis(inputSignal);

            % Concatenate signal features.
            featureValues = Kurtosis;

            % Store computed features in a table.
            featureNames = {'Kurtosis'};
            Case_sigstats_5 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,1);
            featureNames = {'Kurtosis'};
            Case_sigstats_5 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_5},'VariableNames',{'Case_sigstats_5'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P7;
            Kurtosis = kurtosis(inputSignal);

            % Concatenate signal features.
            featureValues = Kurtosis;

            % Store computed features in a table.
            featureNames = {'Kurtosis'};
            Case_sigstats_6 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,1);
            featureNames = {'Kurtosis'};
            Case_sigstats_6 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_6},'VariableNames',{'Case_sigstats_6'})];

        %% Concatenate frames.
        frames = [frames;frame]; %#ok<*AGROW>
    end
    % Append all member results to the cell array.
    memberResult = table({frames},'VariableNames',"FRM_1");
    allMembersResult = [allMembersResult; {memberResult}]; %#ok<AGROW>
end

% Write the results for all members to the ensemble.
writeToMembers(outputEnsemble,allMembersResult)

% Gather all features into a table.
selectedFeatureNames = ["FRM_1/Case_sigstats/Kurtosis","FRM_1/Case_sigstats/PeakValue","FRM_1/Case_sigstats/SINAD","FRM_1/Case_sigstats/SNR","FRM_1/Case_sigstats_1/Kurtosis","FRM_1/Case_sigstats_1/PeakValue","FRM_1/Case_sigstats_1/SINAD","FRM_1/Case_sigstats_2/Kurtosis","FRM_1/Case_sigstats_2/PeakValue","FRM_1/Case_sigstats_3/Kurtosis","FRM_1/Case_sigstats_4/Kurtosis","FRM_1/Case_sigstats_4/PeakValue","FRM_1/Case_sigstats_4/SINAD","FRM_1/Case_sigstats_5/Kurtosis","FRM_1/Case_sigstats_6/Kurtosis"];
featureTable = readFeatureTable(outputEnsemble,"FRM_1",'Features',selectedFeatureNames,'ConditionVariables',outputEnsemble.ConditionVariables,'IncludeMemberID',true);

% Set SelectedVariables to select variables to read from the ensemble.
outputEnsemble.SelectedVariables = unique([outputEnsemble.DataVariables;outputEnsemble.ConditionVariables;outputEnsemble.IndependentVariables],'stable');

% Gather results into a table.
if nargout > 1
    outputTable = readall(outputEnsemble);
end
end
