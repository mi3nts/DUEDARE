% FUNCTION TO MERGE 2 DATA SHEET STRUCTURES 

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function mergedDS = mergeDS(DS1, DS2)
    
     % initialze merged data sheet structure
    mergedDS = DS1;

    % get field names
    fields = string(fieldnames(mergedDS))';

    % iterate through each key to find discrepencies
    for key = fields

        % if key values are not equal, evaluate difference
        if ~strcmp(DS1.(key), DS2.(key))

            % check if DS1 value contains DS2 value
            if contains(DS1.(key), DS2.(key))

                % leave DS1 as the mergedDS.key value

            elseif contains(DS2.(key), DS1.(key))

                % update mergedDS.key value to DS2.key
                mergedDS.(key) = DS2.(key);

            else
                % if values are unique append them
                mergedDS.(key) = strcat(DS1.(key), ", ", DS2.(key));

            end
        end
    end