%% Pipeline di testing task1

%1. run ModellazioneDataset per strutturare il dataset di test
%2. carica funzione relativa alla generazione delle feature senza il
%ranking

%3. Caricare il modello di classificazione addestrato
%4. Applicare il sistema di voting per assegnare la classe predetta in base
%al numwindows
% 5. Calcolare il numero di classi e calcolare metriche di accuraccy
% 6. Plot della matrice di confusione
%7. Confronto con foglio delle risposte per valutazione finale

import generate_feature_FS_FR_128ms_Range5_225Hz.*
import NoRanking_generate_feature_FS_FR_128ms_Range5_225Hz.*
%load('trainedModel1.mat')

% Caricamento file delle risposte per confronto
answers = 'answer.csv';
answers = readtable(answers, 'VariableNamingRule', 'preserve');

% num windows frame policy 0.128s
numWindow = 10;

%Sistema di voting
%Threshold 2/3
dueterzi = int32(numWindow*2/3)+1;

%% 1.Caricamento del Dataset Ristrutturato
run("../ModellazioneDataset.m");

%% 2. Estrazione delle feature

[test_FeatureTable_task1,x] = generate_feature_FS_FR_128ms_Range5_225Hz(challengeDataset);
[test_FeatureTable_task11,y] = NoRanking_generate_feature_FS_FR_128ms_Range5_225Hz(challengeDataset);

%% 3. Addestramento

yfit=trainedModel.predictFcn(test_FeatureTable_task1);
len = length(yfit);

%% Sistema di Voting
prediction = [];

for i = 1:numWindow:len-numWindow+1
            countOfOnes = sum(yfit(i:i+numWindow-1) == 1);
            countOfZeros = numWindow-countOfOnes;
            if countOfOnes>=dueterzi
                prediction = [prediction, 1];
            else
                prediction = [prediction, 0];
            end
end
    
count_normal = length(prediction(prediction == 0));   
count_abnormal = length(prediction(prediction == 1));
 
fprintf('Data classified as normal (class 0): %d \n', count_normal);
fprintf('Data classified as abnormal (class 1): %d \n', count_abnormal);

correct_answer_task1 = answers.task1';
rightPredic = correct_answer_task1 == prediction;

% Calculate accuracy
accuracy = sum(rightPredic) / numel(correct_answer_task1);

% Display accuracy
disp(['Accuracy: ', num2str(accuracy * 100), '%']);

classLabels = {'Normal', 'Abnormal'};

C = confusionmat(correct_answer_task1,prediction1);

figure;
confusionchart(C, classLabels);
sgtitle(['Total Accuracy: ', num2str(accuracy * 100), ' %']);

fig_name = 'image/confusionchart_task1';
set(gcf, 'Position', [150, 150, 600, 500])
saveas(gcf, strcat(fig_name, '.png'));

prediction1 = [answers.ID prediction1'];


plot_data(testFeatureTable1, prediction1(:,2), 1, '');
confronti = (prediction1(:,2)==correct_answer_task1');
plot_data(testFeatureTable1, confronti, 1, 'actual');
