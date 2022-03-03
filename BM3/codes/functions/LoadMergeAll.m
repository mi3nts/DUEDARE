% FUNCTION TO LOAD ALL OBJECTS OF A CERTAIN KIND AND MERGE INTO A SINGLE
% MERGED OBJECT

% INPUTS:
%     dataObjectName = STRING. NAME OF DESIRED OBJECTS. 
%         E.G. 'EEGAccelTobiiTimetable'
%     DEVICE = STRING. ID OF DEVICE USED TO MEASURE DATA OR SYNCHRONIZED
%         E.G. 'EEGXX', 'TobiiXX', 'Synchronized'

% OUTPUT:
%     mergedObject = MERGED OBJECT WITH ALL CONSTITUENT OBJECTS
%     CONCATENATED VERTICALLY

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [mergedObject, fileIDs] = LoadMergeAll(dataObjectName, DEVICE)

    %% FIND ALL FILES OF DESIRED KIND IN OBJECTS FOLDER

    fileIDs = findAllFiles('objects', dataObjectName);
    
    %% CREATE STRUCTURE TO SAVE OBJECTS INTO
    
    objectStruct.objectKind = dataObjectName;

    %% LOAD ALL OBJECTS INTO WORKSPACE
    
    % initialize array to hold number of columns of object
    numColumns = 0;

    for ID = fileIDs

        % get string inputs from ID
        [YEAR, MONTH, DAY, TRIAL, USER] = decodeID(ID);

        % load object corresponding to ID
        [Object, ID] = LoadObject(YEAR, MONTH, DAY,...
            TRIAL, USER, DEVICE, dataObjectName);
        
        % update numColumns array
        sizeObject = size(Object);
        numColumns = [numColumns; sizeObject(2)];

        % rename object to include ID name
        eval(strcat('objectStruct.ID_', ID,' = Object;'));

    end
    
    %% MERGE ALL OBJECTS

    % convert structure to cell array
    objectCell = struct2cell(objectStruct);

    % initialize merged timetable
    mergedObject = [];

    % append timetables in chronological order
    for i = 2:length(objectCell)
        
        % do not merge objects with less columns than max
        if numColumns(i) < max(numColumns)
            continue
        end

        mergedObject = [mergedObject; objectCell{i}];
        
    end
    
    % sortrows of merged object
    mergedObject = sortrows(mergedObject);
    