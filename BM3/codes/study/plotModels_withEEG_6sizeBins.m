clear; close all; clc

% CODE TO CREATE PLOTS TO EVALUATE ML MODELS OF PM USING BM

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

%% OVERHEAD

% grab current directory
curDir = pwd;

% specify subdirectory models
modelID = "BM-9_PM-6_Trials-7_TP-90";
corePath = strcat(curDir,"/Models/", modelID, "_withEEG/");

% import data
load(strcat(corePath, "_data/DUEDARE_", modelID,".mat"))

% add functions and change to homeDir
homeDir

%% ITERATE THROUGH ALL MODELS

% get list of subdirs in core path
filelist = dir(corePath);

for i=1:length(filelist)

    foldername = filelist(i).name;
    if foldername(1) == '.'
        continue
    end
    if foldername(1) == '_'
        continue
    end

    % define path to model folder
    modelPath = strcat(filelist(i).folder, '/');

    % load model
    load(strcat(modelPath,filelist(i).name,"/Model.mat"))
        
    % regression model plots
    regModelPlots(modelPath, Model.Mdl, ...
        Model.YTrain, Model.YTest, ...
        Model.YTrain_predicted, Model.YTest_predicted, ...
        Model.modelName, ...
        Model.XNames, Model.YName)

    % plot true and estimated target time series
    % find index corresponding to proper target variable
    idx = find(strcmp(Model.YName, Targets.Properties.VariableNames));
    Y = Targets(:,idx).Variables; % get target values

    t = Targets.Datetime; % get datetime stamps
%     t = 1:height(Targets);  % get time index
    
    % plot time series and Q-Q plot
    timeSeriesRegPlots(modelPath, Model.Mdl, ...
        t, Predictors.Variables, Y, ...
        Model.modelName, Model.YName)

    close all

end