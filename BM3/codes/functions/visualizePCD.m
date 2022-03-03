% FUNCTION TO PLOT BAR GRAPH OF DISTANCE BETWEEN PUPIL CENTER 

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function axPDD = visualizePCD(TobiiTimetable, ts, cmap)

    b = bar(TobiiTimetable.PupilCenter_Distance(ts) ...
        - nanmean(TobiiTimetable.PupilCenter_Distance));
    b.Parent.XLim = [0.25 1.75];
    b.Parent.YLim = [(-1.05*(max(TobiiTimetable.PupilCenter_Distance) - ...
        nanmean(TobiiTimetable.PupilCenter_Distance))) ...
        (1.15*(max(TobiiTimetable.PupilCenter_Distance) - ...
        nanmean(TobiiTimetable.PupilCenter_Distance)))];
    
    try
        b.FaceColor = cmap(...
            round((256*TobiiTimetable.PupilCenter_Distance(ts)...
            /max(TobiiTimetable.PupilCenter_Distance))),:);
    catch
    end
    
    axPDD = gca; 
    axPDD.XTickLabel = '';
    axPDD.YAxis.FontSize = 16;
    axPDD.Title.String = {'Pupil Center'; 'Distance minus mean (mm)'};
    axPDD.Title.FontSize = 18;

    % update text with difference between pupil sizes
    if ~isnan(TobiiTimetable.PupilCenter_Distance(ts))
        text(1, ...
            0.9*(max(TobiiTimetable.PupilCenter_Distance) ...
            - nanmean(TobiiTimetable.PupilCenter_Distance)),...
            string(round(TobiiTimetable.PupilCenter_Distance(ts) ...
            - nanmean(TobiiTimetable.PupilCenter_Distance),2)), ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 20)
    end
    