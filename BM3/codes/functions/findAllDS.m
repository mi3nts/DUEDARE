% FUNCTION THAT RETURNS IDS OF EVERY DATA SHEET IN BM3

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function fileIDs = findAllDS()
    %% OVERHEAD

    % add dependencies and change dir
    homeDir

    %% CHANGE TO OBJECTS FOLDER

    cd raw

    %% GET LIST OF FILENAMES

    % get current path
    rootdir = pwd;

    % windows case
    if contains(computer, 'WIN')
        seperator = '\';

    % mac and linux case
    else
        seperator = '/';
    end

    % search dir for desired files
    eval(strcat("filelist = dir(fullfile(rootdir, '**",seperator,...
        "*dataSheet.txt'));"));

    %% GENERATE LIST OF FILE IDS

    fileIDs = [];

    for i=1:length(filelist)

        fileIDs = [fileIDs string(filelist(i).name(1:19))];

    end

    % strip any trailing or leading underscores
    fileIDs = strip(fileIDs,'_');

    %% CHANGE TO OBJECTS FOLDER BACK TO BM3

    cd ..