% FUNCTION TO COMPUTE MANUAL TRIGGER POINTS FROM COGNIONICS DATASET

% INPUTS:
%     Timetable = Timetable including cognionics data with wireless trigger

% OUTPUTS:
%     triggerPoints = 2 by N array, where each column gives timetable row
%     indicies of adjacent trigger presses i.e. trigger interval indicies

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function triggerPoints = getTriggerPoints(Timetable)

    % compute difference in trigger values
    iwant8888 = find(Timetable.TRIGGER == 8888);

    % compute difference in trigger values
    triggerValueDiff = diff(iwant8888);

    % find where difference between trigger values is not 1
    iTriggerPoint = find(triggerValueDiff~=1);

    % define trigger points
    triggerPoints = [iwant8888(iTriggerPoint); iwant8888(iTriggerPoint+1)];
end