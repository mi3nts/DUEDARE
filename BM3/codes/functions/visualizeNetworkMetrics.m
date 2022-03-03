% FUNCTION TO PLOT NETWORK METRICS OF INPUT GRANGER NETWORK FROM 64 
% ELECTRODE EEG. THE FOLLOWING METRICS ARE PLOTTED:

% METRICS:
%     1. BETWEENNESS CENTRALITY (NUMBER OF SHORTEST PATHS NODE IS IN)
%     2. AUTHORITIES (NODES WHERE EDGES TEND TO START)
%     3. HUBS (NODES WHERE EDGES TEND TO AGGREGATE)
%     ON IN-EDGES)
%     4. PAGERANK CENTRALITY (NUMBER OF TIMES NODE IS TOUCHED ON RANDOM
%     WALK AROUND NETWROK)
%     ON OUT-EDGES)
%     5. INDEGREE - OUTDEGREE CENTRALITY
%     6. INCLOSENESS - OUTCLOSENESS CENTRALITY


% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = visualizeNetworkMetrics(metrics)

    % load eeg channel locations
    load('backend/channelLocations/EEG01_chanlocs.mat')

    % define colormap
    colormap(jet);

    % get x and y coordinates
    [Y, X] = pol2cart((pi*extractfield(EEG01_chanlocs,'theta'))/180, ...
        extractfield(EEG01_chanlocs,'radius'));

    % scale node locations to matach head drawing
    X = X/1.355;
    Y = Y/1.355;

    % plot betweenness
    subplot(2,3,1)
    plotBrainRegions(1) % plot head drawing with colored brain region
    hold on
    markerSizes = (metrics.C_betweenness+1).^4;
    c = metrics.C_betweenness;
    scatter(X, Y, markerSizes, c, 'filled');
    colorbar('FontSize', 12);
    title({'Betweeness Centrality', '(Mediators)'}, 'FontSize', 18)

    % plot pagerank
    subplot(2,3,4)
    plotBrainRegions(1) % plot head drawing with colored brain region
    hold on
    markerSizes = (metrics.C_pagerank*200).^4;
    c = metrics.C_pagerank;
    scatter(X, Y, markerSizes, c, 'filled');
    colorbar('FontSize', 12);
    title({'Pagerank Centrality', '(Popular Stops)'}, 'FontSize', 18)

    % plot authorities
    subplot(2,3,2)
    plotBrainRegions(1) % plot head drawing with colored brain region
    hold on
    markerSizes = (metrics.C_authorities*200).^4;
    c = metrics.C_authorities;
    scatter(X, Y, markerSizes, c, 'filled');
    colorbar('FontSize', 12);
    title({'Authorities', '(Origins)'}, 'FontSize', 18)

    % plot hubs
    subplot(2,3,3)
    plotBrainRegions(1) % plot head drawing with colored brain region
    hold on
    markerSizes = (metrics.C_hubs*200).^4;
    c = metrics.C_hubs;
    scatter(X, Y, markerSizes, c, 'filled');
    colorbar('FontSize', 12);
    title({'Hubs', '(Destinations)'}, 'FontSize', 18)

    % plot in/outdegree
    subplot(2,3,5)
    plotBrainRegions(1) % plot head drawing with colored brain region
    hold on
    markerSizes = (abs(metrics.C_indegree - metrics.C_outdegree) + 1).^3.5;
    c = (metrics.C_indegree - metrics.C_outdegree);
    scatter(X, Y, markerSizes, c, 'filled');
    colorbar('FontSize', 12);
    title('In - Out Degree', 'FontSize', 18)

    % plot in/outcloseness
    subplot(2,3,6)
    plotBrainRegions(1) % plot head drawing with colored brain region
    hold on
    markerSizes = (abs(metrics.C_incloseness - metrics.C_outcloseness)*100).^3.5;
    c = (metrics.C_incloseness - metrics.C_outcloseness);
    scatter(X, Y, markerSizes, c, 'filled');
    colorbar('FontSize', 12);
    title('In - Out Closeness', 'FontSize', 18)
