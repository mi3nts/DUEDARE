% FUNCTION TO CHECK IF A DATA SHEET EXISTS FOR A GIVEN ID

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [dataSheetExists, filePath] = checkDS(ID)

    % get info from input ID
    [YEAR, MONTH, DAY, TRIAL, USER, ~] = decodeID(ID);

    % create file name from ID
    filename = strcat(YEAR,'_', ...
        MONTH,'_', ...
        DAY,'_', ...
        TRIAL,'_', ...
        USER, '_dataSheet.txt');

    % get path name
    [~, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);
    
    % windows case
    if contains(computer, 'WIN')
        seperator = '\';
        
    % mac and linux case
    else
        seperator = '/';
    end

    % define full file path name
    filePath = strcat('raw',seperator, pathID, seperator, filename);

    dataSheetExists = exist(filePath, 'file');