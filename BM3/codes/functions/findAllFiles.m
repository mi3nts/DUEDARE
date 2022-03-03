% FUNCTION TO FIND ALL DATA FILES OF A CERTAIN KIND IN BM3 AND RETURN THEIR
% BM3 FILE IDs

% INPUTS:

% dataRootFolder = STRING. ROOT FOLDER NAME WHERE DATA IS SAVED. 
%         E.G. 'raw' or 'objects'
% dataObjectName = STRING. NAME OF .MAT FILE
%         E.G. 'EEGAccelTobiiTimetable'

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function fileIDs = findAllFiles(dataRootFolder, dataObjectName)

    %% CHANGE TO OBJECTS FOLDER

    eval(strcat("cd ", dataRootFolder));

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
    eval(strcat("filelist = dir(fullfile(rootdir, '**",seperator,"*", ...
        dataObjectName, ...
        ".mat'));"));

    %% GENERATE LIST OF FILE IDS

    fileIDs = [];

    for i=1:length(filelist)

        fileIDs = [fileIDs string(filelist(i).name(1:19))];

    end

    % strip any trailing or leading underscores
    try
        fileIDs = strip(fileIDs,'_');
    catch
        error('No files found')
    end

    %% CHANGE TO OBJECTS FOLDER BACK TO BM3

    cd ..
    
end