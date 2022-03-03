% FUNCTION TO VISUALIZE ANY QUANITY AT A GIVEN TIMESTEP AS SINGLE BAR PLOT

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function ax = visualizeBar(Array, ts, cmap, titleString)

    b = bar(Array(ts));
    b.Parent.XLim = [0.25 1.75];
    b.Parent.YLim = [0 1.15*...
        max(Array)];
    try
        b.FaceColor = cmap(...
            round((256*Array(ts)/max(Array))),:);
    catch
    end
    ax = gca; ax.XTickLabel = '';
    ax.YAxis.FontSize = 16;
    ax.Title.String = titleString;
    ax.Title.FontSize = 18;

    % update text with quantity value
    text(1, max(Array), ...
        string(round(Array(ts),2)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 20)