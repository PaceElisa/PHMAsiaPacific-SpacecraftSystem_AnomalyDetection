function [training_table,test_table] = train_test_split(FeatureTable,numberOfWindows)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

features_table = FeatureTable;
training_table = FeatureTable;

test_perc = 20;

if ismember('Task1', features_table.Properties.VariableNames)
    % stratified splitting 80-20
    % 1 : 105 normal, 106 : 153 fault, 154 : 177 anomaly
    normal_test_perc = int32(105*test_perc/100);
    fault_test_perc = int32((153-105)*test_perc/100);
    anomaly_test_perc = int32((177-153)*test_perc/100);
    
    anomaly_test = training_table(153*numberOfWindows+1:(anomaly_test_perc+153)*numberOfWindows,:);
    training_table(153*numberOfWindows+1:(anomaly_test_perc+153)*numberOfWindows,:) = [];
    
    fault_test = training_table(105*numberOfWindows+1:(fault_test_perc+105)*numberOfWindows,:);
    training_table(105*numberOfWindows+1:(fault_test_perc+105)*numberOfWindows,:) = [];
    
    normal_test = training_table(1:normal_test_perc*numberOfWindows,:);
    training_table(1:normal_test_perc*numberOfWindows,:) = [];
    
    test_table = [normal_test; fault_test; anomaly_test];
 
end
end