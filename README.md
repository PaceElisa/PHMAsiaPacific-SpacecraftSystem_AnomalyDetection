# PHM-Asia-Pacific 2023---Progetto-C1 di Manutenzione preventiva per la robotica e l'automazione intelligente

I dati di telemetria che possono essere acquisiti in orbita sono ridotti a causa della limitazione nell' installazione di sensori e della capacità di downlink. Per ovviare a ciò la Japan Aerospace Exploration Agency (JAXA) ha sviluppato un simulatore numerico per prevedere la risposta dinamica di un sistema di propulsione di un veicolo spaziale con elevata precisione per generare un set di dati che copra le condizioni normali e tutti gli scenari di guasto previsti nelle apparecchiature reali.
L'obiettivo del progetto è sviluppare un modulo di diagnosi in grado di classificare anomalie, bolle, guasti alle elettrovalvole e casi anomali sconosciuti partendo dai dati generati dal simulatore semplificato del sistema di propulsione sviluppato con la collaborazione di JAXA.
Il progetto si svolgerà, indicativamente, secondo i seguenti punti:
-	leggere la documentazione disponibile nel sito di riferimento;
-	comprendere il dataset e importarlo in MATLAB;
-	strutturare il dataset affinché sia utilizzabile all’interno di Diagnostic Feature Designer, considerando le etichette che dovranno essere strutturate come richiesto dalla competizione;
-	selezionare un’eventuale frame policy;
-	calcolare lo spettro del segnale;
-	selezionare e calcolare le feature diagnostiche da utilizzare;
-	selezionare i classificatori da addestrare per le singole fasi (approccio in “cascata”);
-	valutare come risolvere il problema dell’anomaly detection;
-	selezionare il regressore da addestrare per la fase finale;
-	testare il modulo di diagnosi con apposito dataset (“Testing”);
-	determinare le prestazioni usando una metrica opportuna.

Il materiale di riferimento iniziale consiste in:
-	sito di riferimento, https://phmap.jp/program-data/
-	dataset.
