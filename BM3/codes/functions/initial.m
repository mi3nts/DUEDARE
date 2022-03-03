% FUNCTION TO INITIALIZE NEW BIOMETRIC DATA INTO DIRECTORY STRUCTURE. CODE READS
% ALL FOLDERS IN _newData FOLDER AND CREATES/PUTS IT IN THE PROPER
% DIRECTORY AND CREATES DIRECTORY FOR ANY FUTURE DATA OBJECTS

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% -------------------------------------------------------------------------

function [] = initial()
    % windows case
    if contains(computer, 'WIN')
        seperator = '\';

    % mac and linux case
    else
        seperator = '/';
    end
   
    % change directory to raw/_newData
    eval(strcat("cd raw",seperator,"_newData"));

    % get folder names from _newData folder
    struc = dir;

    % change directory back to home directory
    homeDir

    % iterate thorugh each folder name 
    for i = 1:length(struc)

        % set ID 
        ID = struc(i).name;

        % disregard any non-folders
        if strcmp(ID(1),'.')
            continue
        end

        pathID = strrep(ID,'_', seperator);

        % check if folder corresponding to ID exists for raw data, if not make it
        if ~exist(strcat('raw',seperator,pathID), 'dir')
            mkdir(strcat('raw',seperator,pathID))
        end

        % move folder to proper directory
        try
            eval(strcat("movefile ", strcat('raw',seperator,'_newData',seperator,ID, " "), ...
                strcat('raw',seperator,pathID)));
        catch
            disp(strcat("data already exist for ",ID))
        end

        % check if folder corresponding to ID exists for data objects, if not make it
        if ~exist(strcat('objects',seperator,pathID), 'dir')
            mkdir(strcat('objects',seperator,pathID))
        end

        % check if _Synchronized folder corresponding to ID exists for data 
        % objects, if not make it
        if ~exist(strcat('objects',seperator,pathID(1:19),seperator,'_Synchronized'), 'dir')
            mkdir(strcat('objects',seperator,pathID(1:19),seperator,'_Synchronized'))
        end   
        
        % initialize biometric dataset for dataset
        initialDS(ID)
    end
    
end
