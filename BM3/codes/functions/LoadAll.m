% FUNCTION TO LOAD ALL OBJECTS OF A CERTAIN KIND INTO A DATA STRUCTURE

% INPUTS:
%     dataObjectName = STRING. NAME OF DESIRED OBJECTS. 
%         E.G. 'EEGAccelTobiiTimetable'
%     DEVICE = STRING. ID OF DEVICE USED TO MEASURE DATA OR SYNCHRONIZED
%         E.G. 'EEGXX', 'TobiiXX', 'Synchronized'

% OUTPUT:
%     objectStruct = STRUCTURE WITH FIELDS OF EACH DESIRED OBJECT IN BM3

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [objectStruct, fileIDs] = LoadAll(dataObjectName, DEVICE)

    %% FIND ALL FILES OF DESIRED KIND IN OBJECTS FOLDER

    fileIDs = findAllFiles('objects', dataObjectName);
    
    %% CREATE STRUCTURE TO SAVE OBJECTS INTO
    
    objectStruct.objectKind = dataObjectName;

    %% LOAD ALL OBJECTS INTO WORKSPACE

    for ID = fileIDs

        % get string inputs from ID
        [YEAR, MONTH, DAY, TRIAL, USER] = decodeID(ID);

        % load object corresponding to ID
        [Object, ID] = LoadObject(YEAR, MONTH, DAY,...
            TRIAL, USER, DEVICE, dataObjectName);

        % rename object to include ID name
        eval(strcat('objectStruct.ID_', ID,' = Object;'));

    end