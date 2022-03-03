% FUNCTION TO PLOT BAR GRAPH OF PUPIL DIAMETER DIFFERENCE

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function axPDD = visualizePDD(TobiiTimetable, ts, cmap)


    b = bar(TobiiTimetable.PupilDiameterDifference(ts));
    b.Parent.XLim = [0.25 1.75];
    b.Parent.YLim = [0 1.1*max(TobiiTimetable.PupilDiameterDifference)];
    try
        b.FaceColor = cmap(...
            round(...
            (256*TobiiTimetable.PupilDiameterDifference(ts)...
            /max(TobiiTimetable.PupilDiameterDifference)))...
            ,:);
    catch
    end
    axPDD = gca; axPDD.XTickLabel = '';
    axPDD.YAxis.FontSize = 16;
    axPDD.Title.String = {'Pupil Diameter'; 'Difference (mm)'};
    axPDD.Title.FontSize = 18;

    % update text with difference between pupil sizes
    if ~isnan(TobiiTimetable.PupilDiameterDifference(ts))
        text(1, max(TobiiTimetable.PupilDiameterDifference),...
            string(round(TobiiTimetable.PupilDiameterDifference(ts),2)), ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 20) 
    end
