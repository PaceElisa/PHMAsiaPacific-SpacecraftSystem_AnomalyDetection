% Percentuale di test
test_perc = 10;

% Numero totale di campioni (720)
total_samples = 720;

% Numero di campioni per ogni etichetta
label_1_samples = 480;  % Etichetta 1 (da 1 a 480)
label_2_samples = 240;  % Etichetta 2 (da 481 a 720)

% Calcolare il numero di campioni per il test per ogni etichetta
test_samples_1 = int32(label_1_samples * test_perc / 100);  % Test per etichetta 1
test_samples_2 = int32(label_2_samples * test_perc / 100);  % Test per etichetta 2

% Dividere i dati per etichetta
% Etichetta 1
data_label_1 = FeatureTable_binary(1:label_1_samples, :);  % Campioni con etichetta 1
% Etichetta 2
data_label_2 = FeatureTable_binary(label_1_samples+1:total_samples, :);  % Campioni con etichetta 2

% Creare il training e test set per ciascuna etichetta
% Per etichetta 1
test_label_1 = data_label_1(end-test_samples_1+1:end, :);  % Ultimi campioni per il test
train_label_1 = data_label_1(1:end-test_samples_1, :);  % Restanti campioni per il training

% Per etichetta 2
test_label_2 = data_label_2(end-test_samples_2+1:end, :);  % Ultimi campioni per il test
train_label_2 = data_label_2(1:end-test_samples_2, :);  % Restanti campioni per il training

% Creare il test set finale combinando i test set di entrambe le etichette
test_table = [test_label_1; test_label_2];

% Creare il training set finale combinando i training set di entrambe le etichette
training_table = [train_label_1; train_label_2];


