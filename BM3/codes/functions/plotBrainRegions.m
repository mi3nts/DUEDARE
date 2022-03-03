% FUNCTION TO PLOT BRAIN REGIONS ON TOP OF EEGLAB HEAD DRAWING

% INPUT:
%     includeHead = BOOLEAN. 0 = DO NOT INCLUDE HEAD DRAWING. 1 = INCLUDE 
%     HEAD DRAWING. NOTE: head may break some arrows on directed graph plot!

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function plotBrainRegions(includeHead)

    % add eeglab functions
    addEEGLabFunctions

    % load eeg channel locations
    load('EEG01_chanlocs.mat')
    load('EEG01_eegRegionsOutlines.mat')

    %% GET X-Y COORDINATES

    % get x and y coordinates
    [Y, X] = pol2cart((pi*extractfield(EEG01_chanlocs,'theta'))/180, ...
        extractfield(EEG01_chanlocs,'radius'));

    % adjust coodinates to align with head drawing
    X = X/1.355;
    Y = Y/1.355;
    %% DEFINE COLORMAP

    cmap = [[0 0 1]; [1 1 0]; [0 1 0]; [1 0 0]; [1 0 1]];

    %% GET NODES AND REGIONS

    % get node names from EEG01_chanlocs
    nodeNames = extractfield(EEG01_chanlocs,'labels');

    % get region names from EEG01_eegRegionsOutlines
    regions = fields(EEG01_eegRegionsOutlines);

    %% DEFINE NUDGE PARAMETER
    
    % define parameter to slightly expand each region
    nudge = 0.2;
    %% PLOT NODE REGIONS
    
    % plot head
    if includeHead
        plotHeadEEGLAB();
    end

    hold on
    
    for i = 1:length(regions)

        % get indicies of nodes in ith region based on order in nodeNames
        iregionOutlineNodes = mod(find(nodeNames' == ...
            EEG01_eegRegionsOutlines.(regions{i})'), 64);

        % if index is 0 change to 64
        if sum(~iregionOutlineNodes)

            iregionOutlineNodes(find(iregionOutlineNodes==0)) = 64;
        end

        % get node names in region
        regionOutlineNodes = nodeNames(iregionOutlineNodes);

        % initialize x and y
        x = [];
        y = [];

        % iterate through each node in ith region and get positions
        for node = string(regionOutlineNodes)

            % get x and y coordinates of node in ith region
            x = [x X(find(nodeNames == node))];
            y = [y Y(find(nodeNames == node))];

        end
        
        % compute region midpoint
        midpoint = [mean(x) mean(y)];
        
        % extend points radially from midpoint based on nudge
        x = x + nudge*(x - midpoint(1));
        y = y + nudge*(y - midpoint(2));
        
        % plot extend motor region
        if strcmp(regions{i}, 'MOTOR')
            
            x = [x sort(x, 'descend')];
            y = [y-0.05 y+0.05];
            
        end

        % plot region
        fill(x,y, cmap(i,:), 'FaceAlpha', 0.1, ...
            'EdgeAlpha',  0.1, 'EdgeColor', cmap(i,:));

        % plot left side of temporal region
        if strcmp(regions{i}, 'TEMPORAL')
            fill(-x, -y, cmap(i,:), 'FaceAlpha',  0.1, ...
            'EdgeAlpha',  0.1, 'EdgeColor', cmap(i,:));

        end

    end
    
    hold off
