% FUNCTION TO WRITE A DATA SHEET TO FILE

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = writeDS(DS)

    % create file name from ID
    filename = strcat(DS.YEAR,'_', ...
        DS.MONTH,'_', ...
        DS.DAY,'_', ...
        DS.TRIAL,'_', ...
        DS.USER, '_dataSheet.txt');
    
    

    % get path name
    [~, pathID] = makeIDs(DS.YEAR, DS.MONTH, DS.DAY, DS.TRIAL, DS.USER, []);
    
    % windows case
    if contains(computer, 'WIN')
        seperator = '\';
    % mac and linux case
    else
        seperator = '/';
    end

    % define full file path name
    filePath = strcat('raw',seperator, pathID, seperator, filename);

    % open text file handle
    fileID = fopen(filePath,'w');

    % write header
    fprintf(fileID, 'BIOMETRIC DATA SHEET \n');
    fprintf(fileID, '--------------------- \n');

    % write data sheet contents line by line
    for key = string(fieldnames(DS))'

        % create line to write to file from structure
        line = strcat(key, ": ", getfield(DS, key));
        % write line
        fprintf(fileID, '%s \n', line);

        % write an additional new line if special cases occur
        if strcmp(key, "USER") || ...
                strcmp(key, "HANDEDNESS") || ...
                strcmp(key, "RELEVANT_MEDICAL_HISTORY") || ...
                strcmp(key, "DEVICES") || ...
                strcmp(key, "TRIAL_NOTES") 

            fprintf(fileID, '\n');
        end

    end
    
    % close file handle
    fclose(fileID);

 
