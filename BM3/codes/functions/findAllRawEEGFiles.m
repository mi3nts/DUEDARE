% FUNCTION TO FIND ALL RAW EEG DATA FILES OF A CERTAIN KIND IN BM3 AND 
% RETURN THEIR BM3 FILE IDs

% INPUTS:

%   EEG = STRING. ID OF EEG DEVICE OF INTEREST

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function fileIDs = findAllRawEEGFiles(EEG)

    %% CHANGE TO RAW FOLDER

    cd raw

    %% GET LIST OF FILENAMES

    % define filename from EEG ID
    rawFileName = strcat(EEG,'.eeg');

    % get current path
    rootdir = pwd;
    % search dir for desired files
    eval(strcat("filelist = dir(fullfile(rootdir, '**/*", ...
        rawFileName, ...
        "'));"));

    %% GENERATE LIST OF FILE IDS

    fileIDs = [];

    for i=1:length(filelist)

        fileIDs = [fileIDs string(filelist(i).name(1:25))];

    end

    % strip any trailing or leading periods
    fileIDs = strip(fileIDs,'.');
    %% CHANGE TO OBJECTS FOLDER BACK TO BM3

    cd ..
    
end