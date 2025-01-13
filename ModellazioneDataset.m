%% Caricamento Dataset

%***Salvataggio percorsi dataset
LabelDataset = "dataset/train/labels.xlsx";
TrainingDataset = "dataset/train/data/";


%***Caricamento del dataset con le etichette
labelsTable = readtable(LabelDataset);
%Rinomino i nomi delle colonne interpretate come non valide da\ Matlab
labelsTable = renamevars(labelsTable, {'Var1','Var2','Var3'}, {'Case', 'Spacecraft', 'Condition'});

%***Leggo i vari case contenuti nel percorso TrainingDataset e li salvo
%tutti in un array di celle(container). Dove ogni file .csv viene salvato in una
%distinta cella, quindi avrò tante celle quanti sono i file.
cases = dir(TrainingDataset + "*.csv");
datacontainer = cell(numel(cases), 1);

for k = 1:numel(cases)
    casepath = TrainingDataset + string(cases(k).name);
    datacontainer{k} =readtable(casepath);

end

%% Costruzione Dataset Strutturato secondo le Specifiche della Challenge

%***Tabella che assegan ad ogni case i suoi rispettivi labels per i vari tasks
size = [numel(datacontainer), 6];
varTypes= {'cell', 'double' , 'double', 'double' , 'double' , 'double'};
varNames ={'Case', 'Task1', 'Task2', 'Task3', 'Task4', 'Task5'};
challengeDataset = table('Size', size, 'VariableTypes', varTypes, 'VariableNames', varNames);
challengeDataset(:, 'Case') = datacontainer;

%% Annotazioni per il Task1

%***Per il task 1 i valori vanno settati a 0, se il case opera in
%condizione normale e a 1 se il case opera in condizione di guasto o
%anomalia sconosciuta
challengeDataset(:, 'Task1') = num2cell(~strcmp(labelsTable.Condition, "Normal")); % Imposta gli elementi ad 1 per le righe della tabella LabelTable che sono uguali a "Normal" e poi fa la negazione logica       

%% Annotazioni per il Task2

%***Per il task2 viene asseganto 2 per le
%anomalie causate da bolle ("Anomaly") , 3 per i guasti alle elettrovalvole ("Fault") e 0 per i
%casi normali ("Normal")
labels_types = cell(numel(labelsTable.Condition), 1)
for i= 1:numel(labelsTable.Condition)
    if strcmp(labelsTable.Condition(i, 1), "Normal")
        labels_types{i}= 0;
    elseif strcmp(labelsTable.Condition(i,1), "Fault") 
        labels_types{i}= 3;
    else 
        labels_types{i} = 2;
    end
end

challengeDataset(:,'Task2') = labels_types;

%% Annotazioni per il Task3

%***Questo task si incentra sull'anomalie causate da bolle e verrà
%asseganto l'indice 1, se il guasto si è verificato nella posizione BP1, 2
%per posizione BP2, .... , 8 per la posizione BV1 e 0 altrimenti

for i = 1:numel(datacontainer)

    if labelsTable{i,"BP1"}== "Yes"
        challengeDataset{i,"Task3"} = 1;
    elseif labelsTable{i,"BP2"} == "Yes"
        challengeDataset{i,"Task3"} = 2;
    elseif labelsTable{i,"BP3"} == "Yes"
        challengeDataset{i,"Task3"} = 3;
    elseif labelsTable{i,"BP4"} == "Yes"
        challengeDataset{i,"Task3"} = 4;
    elseif labelsTable{i,"BP5"} == "Yes"
        challengeDataset{i,"Task3"} = 5;
    elseif labelsTable{i,"BP6"} == "Yes"
        challengeDataset{i,"Task3"} = 6;
    elseif labelsTable{i,"BP7"} == "Yes"
        challengeDataset{i,"Task3"} = 7;
    elseif labelsTable{i,"BV1"} == "Yes"
        challengeDataset{i,"Task3"} = 8;
    else
        challengeDataset{i,"Task3"} = 0;
    end


%% Annotazioni per il Task 4

%*** Questo task si incentra sulle elettrovalvole e viene utilizzato
%l'indice 1 se il guasto si trova sulla valvola 1, 2 se si trova sulla
%valvola 2, .... e 0 altrimenti.

if labelsTable{i,'SV1'}~=100
    challengeDataset{i,"Task4"} = 1;
elseif labelsTable{i,'SV2'}~=100
    challengeDataset{i,"Task4"} = 2;
elseif labelsTable{i,'SV3'}~=100
    challengeDataset{i,"Task4"} = 3;
elseif labelsTable{i,'SV4'}~=100
    challengeDataset{i,"Task4"} = 4;
else
    challengeDataset{i,"Task4"} = 0;
end

%% Annotazioni per il Task5

%*** Questo task immette il rapporto di apertura previsto per ognuna delle
%4 valvole

 if labelsTable{i,'SV1'}~=100
    challengeDataset{i,"Task5"} = labelsTable{i,'SV1'};
 elseif labelsTable{i,'SV2'}~=100
    challengeDataset{i,"Task5"} = labelsTable{i,'SV2'};
 elseif labelsTable{i,'SV3'}~=100
    challengeDataset{i,"Task5"} = labelsTable{i,'SV3'};
 elseif labelsTable{i,'SV4'}~=100
    challengeDataset{i,"Task5"} = labelsTable{i,'SV4'};
 else
     challengeDataset{i,"Task5"} = 100;
 end
end

%***Fine
 

        
