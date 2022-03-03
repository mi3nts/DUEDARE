% FUNCTION TO PERFORM INTERPOLATION OF TOBII DATA IN A SYNCHRONIZED
% TIMETABLE

% INPUTS:
%     inTimetable = input synchronized timetable with tobii data

% OUTPUT:
%     outTimetable = timetable with interpolated vaules for tobii data


% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function outTimetable = interpolTobiiNaNs(inTimetable)

    % define array with column indicies of tobii variables
    tobiiIdx = find(...
        strcmp(inTimetable.Properties.VariableNames,...
        'TRIGGER'))+1:length(inTimetable.Properties.VariableNames);

    % compute nan interpolation for each tobii variable column
    for j = tobiiIdx

        % convert timetable column into array to use interpolNaNs function
        temp = timetable2table(inTimetable(:,j));
        temp = temp(:,2);
        temp = table2array(temp);
        try
            temp = interpolNaNs(temp);
        catch
            disp(strcat("Unable to interpolate ", ...
                inTimetable.Properties.VariableNames(j)));
        end
        
        % replace jth column in timetable with interpolated values
        inTimetable(:,j) = array2table(temp);

    end

    outTimetable = inTimetable;