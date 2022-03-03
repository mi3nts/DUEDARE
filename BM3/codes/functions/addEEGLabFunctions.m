% CODE TO GENERATE ADD EEGLAB PATHS

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = addEEGLabFunctions()
%% Add necessary eeglab functions
if contains(computer, 'WIN')

    addpath('.\backend\eeglab2019_1\functions\popfunc');
    addpath('.\backend\eeglab2019_1\functions\adminfunc');
    addpath('.\backend\eeglab2019_1\functions\sigprocfunc');
    addpath('.\backend\eeglab2019_1\functions\guifunc');
    addpath('.\backend\eeglab2019_1\plugins\Fileio20210128');

    % add channel locations to path
    addpath('.\backend\channelLocations\');

else
    
    addpath('./backend/eeglab2019_1/functions/popfunc');
    addpath('./backend/eeglab2019_1/functions/adminfunc');
    addpath('./backend/eeglab2019_1/functions/sigprocfunc');
    addpath('./backend/eeglab2019_1/functions/guifunc');
    addpath('./backend/eeglab2019_1/plugins/Fileio20210128');

    % add channel locations to path
    addpath('./backend/channelLocations/');

end