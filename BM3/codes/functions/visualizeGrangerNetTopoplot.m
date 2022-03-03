% FUNCTION TO VISUALIZE GRANGER CAUSALITY NETWORK OVERLAYED ON
% TOPOGRAPHICAL EEG PLOT

% INPUTS:

%     eegBand = ARRAY WITH N ROWS AND 64 COLUMNS CORRESPONDING TO EEG
%     ELECTRODE VALUES AT N TIMESTEPS.
%     NOTE: to only plot granger net on head drawing, input empty array, []

%     NodeTable = TABLE OF NODE NAMES OF NETWORK. TABLE WITH SINGLE COLUMN 
% CALLED "NAMES" AND STRING ELEMENTS

%     EndNodes = TABLE OF SOURCE TARGET PAIRS CORRESPONDING TO EDGE WIEGHTS
% IN allWeights ARRAY

%     allWeights = ARRAY OF EDGES WEIGHTS WHERE ROWS CORRESPOND TO ROWS IN
% EndNodes Table AND COLUMNS CORRESPOND TO TIMESTEPS

%     maxWeight = MAGNITUDE OF MAXIMUM WEIGHT OCCURING IN allWeights. NOTE:
% better to compute before calling function to avoid unnecessary
% computations.

%     threshold = THRESHOLD VALUE OF WEIGHTS. WEIGHT MAGNITUDES BELOW
% THRESHOLD ARE NOT PLOTTED

%     EEG01_chanlocs = PROPERITARY BM3 STRUCTURE. EEG INFORMATION FOR CGX
% MOBILE-128 WET EEG SYSTEM. LOCATED AT: 'backend/channelLocations/'

%     ts = INTEGER. TIMESTEP.

%     gcCmap = COLORMAP FOR GRANGER NET

% OUTPUT:
    
%     gcPlt = PLOT HANDLE FOR GRANGER NET. NOTE: handle will be empty if
%     plot is not generated

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function gcPlt = visualizeGrangerNetTopoplot(eegBand,NodeTable, EndNodes, ...
    allWeights, maxWeight, threshold, EEG01_chanlocs, ts, gcCmap)

    % clear old topoplot
    cla('reset')

    % if alpha band is empty just plot head drawing
    if isempty(eegBand)
        
        topoplot([], EEG01_chanlocs, 'conv', 'on');
        
    % if alpha band is not empty and not nan create topo plot
    elseif ~isnan(eegBand(ts,1))
        
        % plot new topoplot
        topoplot(eegBand(ts,:), EEG01_chanlocs, 'conv', 'on');
        
    % if alpha band is not empty and nan, skip timestep
    else
        gcPlt = [];
        return
    end
    % define axis for topoplot
    ax1 = gca;

    % define axis for granger net
    ax2 = axes;

    % plot granger net
    gcPlt = visualizeGrangerNet(NodeTable, EndNodes, allWeights, ...
    maxWeight, threshold, EEG01_chanlocs, ts);

    % set node color to black
    gcPlt.NodeColor = [0 0 0];
    % set node size to 3
    gcPlt.MarkerSize = 3;

    % align node positions of gcNet with contour plot
    gcPlt.XData = (gcPlt.XData)/(1.3559*1.77);
    gcPlt.YData = (gcPlt.YData)/1.3566;

    % align axes
    ax2.XLim = ax1.XLim;
    ax2.YLim = ax1.YLim;
    ax1.Position = ax2.Position;
    
    % set color maps
    colormap(ax1,'jet')
    colormap(ax2,gcCmap)

    % merge axes into one
    linkaxes([ax1,ax2]);
