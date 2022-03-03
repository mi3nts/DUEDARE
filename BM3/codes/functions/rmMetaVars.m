% FUNCTION TO REMOVE META-DATA VARIABLES FROM EGGAccel AND Tobii TIMETABLES

% INPUT:
%     inTimetable = INPUT TIMETABLE. THE FOLLOWING KINDS OF TIMETABLES ARE 
%     SUPPORTED: EEGAccelTimetable, TobiiTimetable, EEGAccelTobiiTimetable

% OUTPUT:
%     outTimetable = OUTPUT TIMETABLE. TIMETABLE WITH META-VARIABLES REMOVED

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function outTimetable = rmMetaVars(inTimetable)

% remove non-eyetracking data
notEyeTrackingVar = ["PresentationDatetime" "PipelineVersion" ...
    "VideoDatetime" "EyeVideoTimestamp" "Direction" "Signal" ...
    "EventDatetime" "Type" "Tag"];

% intialize array to hold indicies of meta-variables columns
rmVars = [];

% get indicues of meta-variable columns
for i=1:length(inTimetable.Properties.VariableNames)
    
    varName = char(inTimetable.Properties.VariableNames(i));
    
    if sum(varName == notEyeTrackingVar)
        rmVars = [rmVars; i];
        continue 
    end
   
    if length(varName) <= 3
        continue
    end
    
    % remove ExGs
    if strcmp(varName(1:3), 'ExG')
        rmVars = [rmVars; i];
        continue
    end
    
    % remove Aux
    if strcmp(varName(1:3), 'AUX')
        rmVars = [rmVars; i];
        continue
    end
    
    % remove PacketCounter
    if strcmp(varName(1:4), 'Pack')
        rmVars = [rmVars; i];
        continue
    end
    
    % remove TRIGGER
    if strcmp(varName(1:4), 'TRIG')
        rmVars = [rmVars; i];
        continue
    end
    
    % remove Latency
    if strcmp(varName(1:4), 'Late')
        rmVars = [rmVars; i];
        continue
    end
        
    % remove Tobii Error Vars
    if strcmp(varName(1:4), 'Erro')
        rmVars = [rmVars; i];
        continue
    end
        
    try
        % remove Tobii Gaze Indicies Vars
        if strcmp(varName(1:9), 'GazeIndex')
            rmVars = [rmVars; i];
            continue
        end
    catch
        continue
    end
    
end

% remove meta-variables
outTimetable = removevars(inTimetable, rmVars);