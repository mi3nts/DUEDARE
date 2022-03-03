clear; close all; clc

% CODE TO TRAIN MODELS FOR FULL SIZE DISTRIBUTION OF PM BASED ON BIOMETRIC
% DATA

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

%% OVERHEAD

% get current directory
curDir = pwd;

% cd to home dir
homeDir

% define dataset name
datasetName = "DUEDARE_BM-329_PM-100_Trials-7";
stringArray = split(datasetName,"-");
numTrialsString = stringArray(end);

%% LOAD DATA

load(strcat(curDir, "/data/", datasetName, ".mat"))

%% DEFINE TRAINING DETAILS

% define training set size
trainPercent = .9;

% define number of workers
numWorkers = 6;

% choose predictors
Predictors = Predictors(:,1:9);

% choose targets
Targets = Targets(:,1:6);

%% TRAIN MODELS

% get num models
 [~, numModels] = size(Targets);

% get num predictors
[~, numVars] = size(Predictors);

% get predictor data as array
X = Predictors.Variables;

for i=1:numModels
% define input and output data
        
    % define target
    Y = Targets(:,i);
    Y = Y.Variables;

    if sum(Y)==Inf
        continue
    end

    % get training and testing sets
    [XTrain, YTrain, XTest, YTest] = getTraining(X, Y, trainPercent);
    %% TRAIN MODEL

    Mdl = trainTreeEnsemble(XTrain, YTrain, numWorkers);
    %% USE MODEL

    % apply model to training set
    YTrain_predicted = predict(Mdl, XTrain);

    % apply model to testing set
    YTest_predicted = predict(Mdl, XTest);

    %% ADD MODEL AND ARRAYS TO DATA STRUCUTRE

    % create model name and store in ModelNames
    modelName = strcat("BM-", string(numVars), ...
        "_PM-",string(numModels), ...
        "_Trials-", numTrialsString, ...
        "_TP-", string(100*trainPercent), ...
        "_Target-", Targets.Properties.VariableNames(i));

    % save model and other quantities to Models data structure
    Model.modelName = modelName;
    Model.Mdl = Mdl;
    Model.XTrain = XTrain;
    Model.YTrain = YTrain;
    Model.YTrain_predicted = YTrain_predicted;
    Model.XTest = XTest;
    Model.YTest = YTest;
    Model.YTest_predicted = YTest_predicted;
    Model.XNames = Predictors.Properties.VariableNames;
    Model.YName = Targets.Properties.VariableNames(i);

    %% SAVE DATA STRUCTURE TO FILE

    % create new directory corresponding to model name
    newDirectory = strcat(curDir,"/Models/BM-", string(numVars), ...
        "_PM-",string(numModels), ...
        "_Trials-", numTrialsString, ...
        '_TP-',string(100*trainPercent), "/", modelName);
    createDir(newDirectory)

    % save data structure to file
    save(strcat(newDirectory, '/Model.mat'), 'Model');

    % clear model from workspace
    clear Model
    close all
end

% save training data
dataDirectory = strcat(curDir,"/Models/BM-", string(numVars), ...
        "_PM-",string(numModels), ...
        "_Trials-", numTrialsString, ...
        '_TP-',string(100*trainPercent), "/_data");
createDir(dataDirectory)


save(strcat(dataDirectory, '/DUEDARE_BM-',string(width(Predictors)), ...
    '_PM-', string(width(Targets)),...
    '_Trials-', numTrialsString,...
    '_TP-',string(100*trainPercent), ...
    '.mat'), ...
    'Predictors', 'Targets')
