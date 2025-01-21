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
% This function computes spectra:
%  Case_ps/SpectrumData
%  Case_ps_1/SpectrumData
%  Case_ps_2/SpectrumData
%  Case_ps_3/SpectrumData
%  Case_ps_4/SpectrumData
%  Case_ps_5/SpectrumData
%  Case_ps_6/SpectrumData
%
% This function computes features:
%  Case_sigstats/SINAD
%  Case_sigstats_2/SINAD
%  Case_sigstats_2/SNR
%  Case_ps_spec/PeakAmp1
%  Case_ps_spec/PeakFreq2
%  Case_ps_1_spec/PeakAmp1
%  Case_ps_1_spec/PeakAmp2
%  Case_ps_1_spec/PeakFreq2
%  Case_ps_2_spec/PeakAmp1
%  Case_ps_2_spec/PeakFreq2
%  Case_ps_3_spec/PeakAmp1
%  Case_ps_3_spec/PeakFreq2
%  Case_ps_4_spec/PeakAmp1
%  Case_ps_4_spec/PeakAmp2
%  Case_ps_4_spec/PeakFreq1
%  Case_ps_4_spec/BandPower
%  Case_ps_5_spec/PeakAmp1
%  Case_ps_5_spec/PeakAmp2
%  Case_ps_6_spec/PeakAmp1
%  Case_ps_6_spec/PeakFreq2
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

% Auto-generated by MATLAB on 20-Jan-2025 14:56:08

% Create output ensemble.
outputEnsemble = workspaceEnsemble(inputData,'DataVariables',"Case",'ConditionVariables',"Task1");

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
    Case_full = readMemberData(member,"Case",["TIME","P1","P3","P2","P4","P5","P6","P7"]);

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
            SINAD = sinad(inputSignal);

            % Concatenate signal features.
            featureValues = SINAD;

            % Store computed features in a table.
            featureNames = {'SINAD'};
            Case_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,1);
            featureNames = {'SINAD'};
            Case_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats},'VariableNames',{'Case_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = Case.P3;
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);

            % Concatenate signal features.
            featureValues = [SINAD,SNR];

            % Store computed features in a table.
            featureNames = {'SINAD','SNR'};
            Case_sigstats_2 = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'SINAD','SNR'};
            Case_sigstats_2 = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_sigstats_2},'VariableNames',{'Case_sigstats_2'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P1;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,10,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps = ps;
        catch
            Case_ps = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps},'VariableNames',{'Case_ps'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P2;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,10,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps_1 = ps;
        catch
            Case_ps_1 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_1},'VariableNames',{'Case_ps_1'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P3;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,10,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps_2 = ps;
        catch
            Case_ps_2 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_2},'VariableNames',{'Case_ps_2'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P4;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,10,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps_3 = ps;
        catch
            Case_ps_3 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_3},'VariableNames',{'Case_ps_3'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P5;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,10,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps_4 = ps;
        catch
            Case_ps_4 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_4},'VariableNames',{'Case_ps_4'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P6;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,10,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps_5 = ps;
        catch
            Case_ps_5 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_5},'VariableNames',{'Case_ps_5'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";
            tuTime = tuReal;

            % Compute effective sampling rate.
            tNumeric = time2num(Case.TIME,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = Case.P7;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Compute the autoregressive model.
            data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
            arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
            model = ar(data,10,arOpt);

            % Compute the power spectrum.
            [ps,w] = spectrum(model);
            ps = reshape(ps, numel(ps), 1);

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            Case_ps_6 = ps;
        catch
            Case_ps_6 = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_6},'VariableNames',{'Case_ps_6'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps.SpectrumData;
            w = Case_ps.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*5) & (w<=factor*225);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',2);
            peakAmp = [peakAmp(:); NaN(2-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(2-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakFreq2 = peakFreq(2);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakFreq2];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakFreq2'};
            Case_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'PeakAmp1','PeakFreq2'};
            Case_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_spec},'VariableNames',{'Case_ps_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_1.SpectrumData;
            w = Case_ps_1.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*5) & (w<=factor*225);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',2);
            peakAmp = [peakAmp(:); NaN(2-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(2-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakAmp2 = peakAmp(2);
            PeakFreq2 = peakFreq(2);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakAmp2,PeakFreq2];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakAmp2','PeakFreq2'};
            Case_ps_1_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'PeakAmp1','PeakAmp2','PeakFreq2'};
            Case_ps_1_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_1_spec},'VariableNames',{'Case_ps_1_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_2.SpectrumData;
            w = Case_ps_2.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*5) & (w<=factor*225);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',2);
            peakAmp = [peakAmp(:); NaN(2-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(2-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakFreq2 = peakFreq(2);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakFreq2];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakFreq2'};
            Case_ps_2_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'PeakAmp1','PeakFreq2'};
            Case_ps_2_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_2_spec},'VariableNames',{'Case_ps_2_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_3.SpectrumData;
            w = Case_ps_3.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*5) & (w<=factor*225);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',2);
            peakAmp = [peakAmp(:); NaN(2-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(2-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakFreq2 = peakFreq(2);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakFreq2];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakFreq2'};
            Case_ps_3_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'PeakAmp1','PeakFreq2'};
            Case_ps_3_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_3_spec},'VariableNames',{'Case_ps_3_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_4.SpectrumData;
            w = Case_ps_4.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*5) & (w<=factor*225);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',2);
            peakAmp = [peakAmp(:); NaN(2-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(2-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakAmp2 = peakAmp(2);
            PeakFreq1 = peakFreq(1);
            BandPower = trapz(w/factor,ps);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakAmp2,PeakFreq1,BandPower];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakAmp2','PeakFreq1','BandPower'};
            Case_ps_4_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,4);
            featureNames = {'PeakAmp1','PeakAmp2','PeakFreq1','BandPower'};
            Case_ps_4_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_4_spec},'VariableNames',{'Case_ps_4_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_5.SpectrumData;
            w = Case_ps_5.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*5) & (w<=factor*225);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',2);
            peakAmp = [peakAmp(:); NaN(2-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(2-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakAmp2 = peakAmp(2);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakAmp2];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakAmp2'};
            Case_ps_5_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'PeakAmp1','PeakAmp2'};
            Case_ps_5_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_5_spec},'VariableNames',{'Case_ps_5_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = Case_ps_6.SpectrumData;
            w = Case_ps_6.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*5) & (w<=factor*225);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',2);
            peakAmp = [peakAmp(:); NaN(2-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(2-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakFreq2 = peakFreq(2);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakFreq2];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakFreq2'};
            Case_ps_6_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,2);
            featureNames = {'PeakAmp1','PeakFreq2'};
            Case_ps_6_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({Case_ps_6_spec},'VariableNames',{'Case_ps_6_spec'})];

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
selectedFeatureNames = ["FRM_1/Case_sigstats/SINAD","FRM_1/Case_sigstats_2/SINAD","FRM_1/Case_sigstats_2/SNR","FRM_1/Case_ps_spec/PeakAmp1","FRM_1/Case_ps_spec/PeakFreq2","FRM_1/Case_ps_1_spec/PeakAmp1","FRM_1/Case_ps_1_spec/PeakAmp2","FRM_1/Case_ps_1_spec/PeakFreq2","FRM_1/Case_ps_2_spec/PeakAmp1","FRM_1/Case_ps_2_spec/PeakFreq2","FRM_1/Case_ps_3_spec/PeakAmp1","FRM_1/Case_ps_3_spec/PeakFreq2","FRM_1/Case_ps_4_spec/PeakAmp1","FRM_1/Case_ps_4_spec/PeakAmp2","FRM_1/Case_ps_4_spec/PeakFreq1","FRM_1/Case_ps_4_spec/BandPower","FRM_1/Case_ps_5_spec/PeakAmp1","FRM_1/Case_ps_5_spec/PeakAmp2","FRM_1/Case_ps_6_spec/PeakAmp1","FRM_1/Case_ps_6_spec/PeakFreq2"];
featureTable = readFeatureTable(outputEnsemble,"FRM_1",'Features',selectedFeatureNames,'ConditionVariables',outputEnsemble.ConditionVariables,'IncludeMemberID',true);

% Set SelectedVariables to select variables to read from the ensemble.
outputEnsemble.SelectedVariables = unique([outputEnsemble.DataVariables;outputEnsemble.ConditionVariables;outputEnsemble.IndependentVariables],'stable');

% Gather results into a table.
if nargout > 1
    outputTable = readall(outputEnsemble);
end
end
