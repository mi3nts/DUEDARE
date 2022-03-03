% FUNCTION TO INITIALIZE DATA SHEET FOR NEW DATASET

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = initialDS(ID)

    % create new data sheet
    DS1 = createDS(ID);

    % check if data sheet exists
    [dataSheetExists, filePath] = checkDS(ID);

    % if it exists compare new data sheet to existing
    if dataSheetExists

        % read existing  data sheet
        DS2 = readDS(filePath);

        % compare new data sheet and existing
        dataSheetsEqual = isequaln(DS1,DS2);

        % if new and existing data sheets are not equal, merge them
        if ~dataSheetsEqual

            % merge data sheets
            mergedDS = mergeDS(DS1, DS2);
            
            % write merged data sheet to file
            writeDS(mergedDS)

        end

    % if a data sheet doesn't exist, write new one to file
    else

        % write data sheet to file
        writeDS(DS1)

    end