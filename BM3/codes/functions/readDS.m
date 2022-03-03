% FUNCTION TO READ A DATA SHEET FROM FILE

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function DS = readDS(filePath) 

    % open file
    fileID = fopen(filePath,'r');

    % get header
    fgetl(fileID);
    fgetl(fileID);

    % initialize a cell array
    cellArray = {};

    while ~feof(fileID)

        % get line
        line = fgetl(fileID);

        % if line is empty skip
        if isempty(line)
            continue
        end

        % append line contents to cell array
        cellArray = [cellArray; strip(split(line, ":"))'];
    end

    % close file
    fclose(fileID);

    % convert cell array to structure
    DS = cell2struct(cellArray(:,2), cellArray(:,1));