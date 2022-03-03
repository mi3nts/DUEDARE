% FUNCTION TO PLOT BAR GRAPH OF HEART RATE
% 
% INPUTS:
% 
%     EEGAccelTobiiTimetable = TIMETABLE WITH HR DATA.
%     ts = INTEGER. INDEX OF TIMESTEP TO PLOT.
%     cmap = COLORMAP TO USE IN PLOTTING BAR.
%         NOTE: SET AS EMPTY (E.G. []) IF HR ZONES FROM 
%         (Siddle & Grossman 1997) ARE DESIRED

% OUTPUT:
% 
%     axHR = AXIS HANDLE FOR PLOT

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function ax = visualizeHR(EEGAccelTobiiTimetable, ts, cmap)


%     text(1, 130, 'Optimal Level', 'Fontsize', 16, ...
%         'HorizontalAlignment', 'center')

    
    % plot heart rate as bar
    b = bar(EEGAccelTobiiTimetable.HR(ts));
    b.Parent.XLim = [0.25 1.75];
    b.Parent.YLim = [0 220];
    
    hold on
    % plot optimal zone lines
    plot([0 1.7500], [115 115], 'r--', 'LineWidth', 2)
    plot([0 1.7500], [145 145], 'r--', 'LineWidth', 2)
    hold off
    if isempty(cmap)
    
        % if no colormap is specified, set colorbar color based on HR zones 
        % from (Siddle & Grossman 1997)
        if EEGAccelTobiiTimetable.HR(ts) <= 80

            % set color to white
            b.FaceColor = 'white';

        elseif EEGAccelTobiiTimetable.HR(ts) > 80 && EEGAccelTobiiTimetable.HR(ts) <= 115

            % set color to yellow
            b.FaceColor = 'yellow';

        elseif EEGAccelTobiiTimetable.HR(ts) > 115 && EEGAccelTobiiTimetable.HR(ts) <= 145

            % set color to red
            b.FaceColor = 'red';

        elseif EEGAccelTobiiTimetable.HR(ts) > 145 && EEGAccelTobiiTimetable.HR(ts) <= 175

            % set color to gray
            b.FaceColor = [0.5 0.5 0.5];

        elseif EEGAccelTobiiTimetable.HR(ts) > 175

            % set color to black
            b.FaceColor = 'black';

        end
    
    else
        % if colormap is specifed use it to set bar colorface
        b.FaceColor = cmap(EEGAccelTobiiTimetable.HR(ts) + 50,:);
        
    end
    
    ax = gca; ax.XTickLabel = '';
    ax.YAxis.FontSize = 16;
    ax.Title.String = 'Heart Rate (bpm)';
    ax.Title.FontSize = 18;
    text(1, 200, string(EEGAccelTobiiTimetable.HR(ts)), 'Fontsize', 32, ...
        'Fontweight', 'bold', 'HorizontalAlignment', 'center')
    
    
    
    