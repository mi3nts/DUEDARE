% FUNCTION TO LIST SUBDIRECTORY NAMES IN CURRENT FOLDER

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function subdirList = subDirs()

    % get current dir structure 
    dirStruct = dir;

    % initialize list to store sub dir names as strings
    subdirList = [];
    
    % store subdir names in list
    for i=1:length(dirStruct)
        
        element = dirStruct(i).name;
        
        if strcmp(string(element(1)),'.')
            continue
        end
        subdirList = [subdirList string(element)];
    end

    
end