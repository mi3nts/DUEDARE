% FUNCTION TO INITIALIZE ALL DATA SHEETS FOR A GIVEN DEVICE ID

% INPUTS:
%     DEVICE =  DEVICE ID STRING. SUPPORTED INPUTS EEG OR TOBII

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = initialAllDS(DEVICE)

%% FIND ALL RAW FILE IDs

% find all EEG and Tobii IDs
eegIDs = findAllRawEEGFiles(DEVICE);
tobiiIDs = findAllRawTobiiFiles(DEVICE);

% merge file IDs into single array
IDs = [eegIDs tobiiIDs];

%% INTIALIZE DATA SHEETS

for ID = IDs
    
    % initialize data sheet
    initialDS(ID)
    
end

