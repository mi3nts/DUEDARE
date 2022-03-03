% FUNCTION TO VISUALIZE GRANGER CAUSALITY GRAPH BASED ON THE FOLLOWING
% INPUTS AND COMPUTE VARIOUS NETWORK METRICS 

% INPUTS:

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

% OUTPUTS:

%     plt = AXIS OBJECT OF GRAPH PLOT
%     c = COLOR BAR OBJECT
%     G = DIGRAPH OBJECT

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)    

function [plt, c, G, metrics] = visualizeGrangerNetWithMetrics(NodeTable, ...
    EndNodes, allWeights, maxWeight, threshold, EEG01_chanlocs, ts)

    % define ith edgetable
    EdgeTable = [EndNodes table(allWeights(:,ts),'VariableNames', {'Weight'})];

    % create digraph
    G = digraph(EdgeTable, NodeTable);
    
    % compute network metrics
    metrics = getDigraphMetrics(G);

    % find node pairs with weight less than threshold
    iwantSmallWeight = find(abs(G.Edges.Weight) <= threshold);

    % remove edges with weights below threshold
    G = rmedge(G, iwantSmallWeight);

    % if weights are nan remove all edges
    if isnan((allWeights(:,ts)))
        G = rmedge(G, 1:height(G.Edges));
    end

    % plot ith digraph
    plt = plot(G);

    % remove node labels
    plt.NodeLabel = '';
    plt.Interpreter = 'none';
    
    % get x and y coordinates
    [Y, X] = pol2cart((pi*extractfield(EEG01_chanlocs,'theta'))/180, ...
        extractfield(EEG01_chanlocs,'radius'));

    % scale node locations to matach head drawing
    plt.XData = X/1.355;
    plt.YData = Y/1.355;

    % change marker and arrow size
    plt.MarkerSize = 1;
    plt.ArrowSize = 16;

    % change edge colors to correspond to weight
    plt.EdgeCData = G.Edges.Weight/maxWeight;

    % define sizes based on current axis size
    ax = gca;
    ax.Units = 'inches';
    
    % update linewidths
    plt.LineWidth = (sqrt(ax.Position(3)*ax.Position(4)))*...
        (abs(G.Edges.Weight)/maxWeight);
    
    % change arrow size based on current axis size
    plt.ArrowSize = (ax.Position(3)*ax.Position(4))^(2/3);
    
    % change units back to normalized
    ax.Units = 'normalized';

    % add colorbar whose limits do not change
    c = colorbar;
    caxis('manual');
    c.Label.String = 'Scaled Granger Causality';
    c.Label.FontSize = 20;
    
    % turn off axis
    ax = gca;
    ax.Visible = 'off';

end