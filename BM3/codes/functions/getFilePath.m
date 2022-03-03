% FUNCTION TO SAVE OBJECT THAT IS ANALYSIS READY DATA STRUCTURE IN BM3

% INPUT:
%     ID = STRING. DATASET ID
%     objectName = STRING. GENERIC OBJECT NAME. EX: EEGAccelTimetable
% Output: 
%     filePath = STRING. PATH WITH FILENAME OF WHERE TO SAVE FILE

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function filePath = getFilePath(subdir, ID, objectName)
    
    % windows case
    if contains(computer, 'WIN')
        seperator = '\';
        
    % mac and linux case
    else
        seperator = '/';
    end

    % create folder for object if it does not exist
    directory = strcat(pwd, seperator, subdir, seperator, ...
        strrep(ID,'_',seperator), seperator);
    createDir(directory)
    
    % create object path
    filePath = strcat(directory, ID, '_', objectName);