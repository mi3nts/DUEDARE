% FUNCTION TO GET PRETTY VARIABLE NAMES FROM INPUT TABLE

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function prettyVarNames = getPrettyNames(Table)

    % load pretty variable names
    load('backend/prettyVariableNames/variableNameTable.mat')

    % initialize prettyVarNames array
    prettyVarNames = [];

    % iteratively add pretty names
    for variable = string(Table.Properties.VariableNames)
        % try to get pretty name 
        try
            eval(strcat('prettyVarNames = [prettyVarNames; variableNameTable.', ...
                variable, '];'));
        % if pretty name doesn't exist use original name
        catch
            prettyVarNames = [prettyVarNames; variable];
        end
    end