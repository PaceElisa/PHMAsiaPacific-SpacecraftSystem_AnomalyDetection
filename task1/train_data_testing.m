% num windows frame policy 0.128s
numWindow = 10;

%maggioranza = int32(numWindow/2)+1;
dueterzi = int32(numWindow*2/3)+1;

trainingTB = training_table;
testingTB = test_table;
% trainTable = FeatureTableTrain;


% [yfit,scores]=trainedModel1.predictFcn(testTable);
yfit=trainedModel.predictFcn(testingTB);
len = length(yfit);

labels = testingTB.Task1;
label_container = [];
for i = 1:numWindow:len-numWindow+1
    label_container = [label_container,labels(i)];
end

prediction = [];

if ismember('Task1', trainingTB.Properties.VariableNames)
    for i = 1:numWindow:len-numWindow+1
        countOfOnes = sum(yfit(i:i+numWindow-1) == 1);
        countOfZeros = numWindow-countOfOnes;
        if countOfOnes>=dueterzi
            prediction = [prediction, 1];
        else
            prediction = [prediction, 0];
        end
    end
    
    correctPredictions = label_container == prediction;%array riga logico che contiene 
    %wrongPredictions = sum(prediction == 1)
    
    % Calculate accuracy
    accuracy = sum(correctPredictions) / numel(label_container);
    
    % Display accuracy
    disp(['Accuracy: ', num2str(accuracy * 100), '%']);
    
    classLabels = {'Normal', 'Abnormal'};
    
    C = confusionmat(label_container,prediction);
    confusionchart(C, classLabels)
end