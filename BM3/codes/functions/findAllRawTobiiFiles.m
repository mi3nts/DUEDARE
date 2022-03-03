% FUNCTION TO FIND ALL RAW TOBII DATASETS IN BM3 LIBRARY AND RETURN THEIR
% BM3 IDS

%   TOBII = STRING. ID OF TOBII DEVICE OF INTEREST

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function fileIDs = findAllRawTobiiFiles(Tobii)

    %% CHANGE TO RAW FOLDER

    cd raw

    %% GET LIST OF FILENAMES

    % get current path
    rootdir = pwd;
    % search dir for desired files
    eval(strcat("filelist = dir(fullfile(rootdir, '**/*",...
        Tobii, ...
        "/participant.json'));"));

    %% GENERATE LIST OF FILE IDS

    % initialize array to store fileIDs
    fileIDs = [];

    for i=1:length(filelist)
        
        % get fileIDs from filelist
        temp = split(filelist(i).folder,'/');
        fileIDs = [fileIDs string(temp(end))];

    end
    %% CHANGE TO OBJECTS FOLDER BACK TO BM3

    cd ..
