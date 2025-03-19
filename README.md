# 🚀 PHM23 Spacecraft Propulsion System Anomaly Detection

## Introduction

Japan Aerospace Exploration Agency (JAXA) aims to enhance Prognostics and Health Management (PHM) technology for spacecraft propulsion systems. Due to limitations in sensor installations and downlink capacity, telemetry data acquired in orbit is restricted. To address this challenge, a numerical simulator has been developed to predict the dynamic response of a spacecraft propulsion system with high accuracy. This simulator generates datasets that cover both normal conditions and anticipated fault scenarios.

## 🎯 Competition Objectives

The goal of this competition is to improve PHM technology for next-generation spacecraft by diagnosing different system states, including:
- Normal cases
- Bubble anomalies
- Solenoid valve faults
- Unknown anomalies

Participants use a dataset generated from a simplified propulsion system simulator developed in collaboration with JAXA.

## Experiment Scenarios

The experimental propulsion system uses water pressurized to 2 MPa, discharged through four solenoid valves (SV1 – SV4), simulating thrusters. Pressure sensors (P1 – P8) capture time-series data at a sampling rate of 1 kHz over 1200 ms. By opening and closing the solenoid valves, pressure fluctuations occur due to the water hammer effect and acoustic modes.

### Types of Anomalies:
- **Bubble anomaly:** Changes in speed of sound due to air bubbles alter pressure fluctuations. The location of bubbles (BV1, BP1–BP7) must be identified.
- **Solenoid valve faults:** Affected valves do not fully open or close, reducing fluid flow. The faulty valve (SV1–SV4) and its opening ratio (between 0% and 100%) must be determined.
- **Unknown anomalies:** Unexpected failures must be identified without confusing them with known faults.

## 🎯 Prediction Goals

The competition requires predicting the following:
1. Normal or abnormal condition.
2. Type of anomaly (bubble anomaly, solenoid valve fault, unknown fault).
3. Location of the bubble anomaly (if applicable).
4. Faulty solenoid valve (if applicable).
5. Opening ratio of the faulty valve (if applicable).

## 📂 Dataset Structure

The dataset consists of training and test data:

```plaintext
├── dataset
│   ├── train
│   │   ├── data
│   │   │   └── Case1~177.csv
│   │   └── labels.xlsx
│   ├── test
│   │   ├── data
│   │   │   └── Case178~223.csv
│   │   └── labels_spacecraft.xlsx
│   ├── submission.csv
│   └── readme.pdf
```

- CSV files contain time-series data (time column + pressure measurements P1–P7).
- Training data includes spacecraft 1–3; test data includes spacecraft 1 and 4.
- Labels files provide details about experimental conditions.

## Evaluation Metrics

The scoring system is based on correctly classifying anomalies and faults, with additional weight for spacecraft 4 data:
- Normal/Abnormal classification: **10 points**
- Bubble anomaly/Solenoid valve fault/Unknown fault classification: **10 points**
- Bubble location identification: **10 points**
- Faulty solenoid valve identification: **10 points**
- Valve opening ratio prediction: `max(-|truth – prediction|+20, 0)`

## Project Structure

This project was developed using MATLAB, utilizing the following tools:
- **Diagnostic Features Designer**: Feature extraction
- **Classification Learner**: Model training for classification tasks
- **Regression Learner**: Model training for regression tasks
- **Experiment Manager**: Hyperparameter tuning

### 📂 Folder Organization

```plaintext
├── dataset
├── task1  # Normal/Abnormal classification
│   ├── featuresExtraction
│   ├── hyperparameterTuning
│   ├── preprocessingData
│   ├── testing
│   ├── training
├── Task_2  # Anomaly type classification
│   ├── OC_SVM
│   ├── binaryClassification
│   ├── preprocessingData
│   ├── testing
├── Task_3  # Bubble anomaly location detection
│   ├── featuresExtraction
│   ├── preprocessingData
│   ├── testing
│   ├── training
├── Task_4  # Solenoid valve fault identification
│   ├── featuresExtraction
│   ├── preprocessingData
│   ├── testing
│   ├── training
├── Task_5  # Valve opening ratio regression
│   ├── featuresExtraction
│   ├── preprocessingData
│   ├── testing
│   ├── training
├── Pipeline_Finale.m  # Master script to run all tasks sequentially
```

Each task folder contains:
- **Preprocessing**: Data cleaning and preparation
- **Feature_Extraction**: Using MATLAB Diagnostic Features Designer
- **Training**: Using Classification and Regression Learner apps
- **Tuning**: Hyperparameter optimization using Experiment Manager
- **Test_Pipeline**: Independent testing pipelines for each task

The final execution script, `Pipeline_Finale.m`, integrates all tasks into a cascaded pipeline. It allows testing each task separately or running the full workflow.

## Usage

1. Clone the repository:
   ```sh
   git clone https://github.com/PaceElisa/PHM_Asia_Pacific_Progetto_C1.git
   ```
2. Open MATLAB and navigate to the project directory.
3. Run `Pipeline_Finale.m` to execute the full pipeline.
4. Alternatively, execute individual test pipelines in each task folder.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

