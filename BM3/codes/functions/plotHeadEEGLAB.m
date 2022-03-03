% FUNCTION TO PLOT EEGLAB HEAD DRAWING

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function plotHeadEEGLAB()

    % add eeglab functions
    addEEGLabFunctions

    % load eeg channel locations
    load('EEG01_chanlocs.mat')
    load('EEG01_eegRegionsOutlines.mat')

    % add topoplot_connect to path
    addpath('./backend/topoplot_connect')
    ds.chanPairs = []; % create dummy data structure to input into topoplot_connect
    
    % plot head
    topoplot_connect(ds, EEG01_chanlocs);