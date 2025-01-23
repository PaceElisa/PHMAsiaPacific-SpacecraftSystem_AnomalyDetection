test_perc = 20;

% num windows fame policy 0.128s
num_window = 10;

features_table = FeatureTable1;
training_table = FeatureTable1;


if ismember('Task1', features_table.Properties.VariableNames)
    % stratified splitting 80-20
    % 1 : 105 normal, 106 : 153 fault, 154 : 177 anomaly
    normal_test_perc = int32(105*test_perc/100);
    fault_test_perc = int32((153-105)*test_perc/100);
    anomaly_test_perc = int32((177-153)*test_perc/100);
    
    anomaly_test = training_table(153*num_window+1:(anomaly_test_perc+153)*num_window,:);
    training_table(153*num_window+1:(anomaly_test_perc+153)*num_window,:) = [];
    
    fault_test = training_table(105*num_window+1:(fault_test_perc+105)*num_window,:);
    training_table(105*num_window+1:(fault_test_perc+105)*num_window,:) = [];
    
    normal_test = training_table(1:normal_test_perc*num_window,:);
    training_table(1:normal_test_perc*num_window,:) = [];
    
    test_table = [normal_test; fault_test; anomaly_test];
 
end