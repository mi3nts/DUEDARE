% FUNCTION TO COMPUTE THE FOLLOWING NETWORK METRICS OF AN INPUT DIRECTED
% GRAPH

% METRICS:
%     1. INDEGREE CENTRALITY (NUMBER OF NODES CONNECTED VIA IN-EDGES)
%     2. OUTDEGREE CENTRALITY (NUMBER OF NODES CONNECTED VIA OUT-EDGES)
%     3. INCLOSENESS CENTRALITY (HOW CLOSE NODE IS TO ALL OTHER NODES BASED
%     ON IN-EDGES)
%     4. OUTCLOSENESS CENTRALITY (HOW CLOSE NODE IS TO ALL OTHER NODES BASED
%     ON OUT-EDGES)
%     5. BETWEENNESS CENTRALITY (NUMBER OF SHORTEST PATHS NODE IS IN)
%     6. PAGERANK CENTRALITY (NUMBER OF TIMES NODE IS TOUCHED ON RANDOM
%     WALK AROUND NETWROK)
%     7. HUBS (NODES WHERE EDGES TEND TO AGGREGATE)
%     8. AUTHORITIES (NODES WHERE EDGES TEND TO START)

% INPUT:
%     G = DIGRAPH HANDLE

% OUTPUT:
%     metrics = STRUCTURE WITH METRICS SAVED AS KEY VALUE PAIRS

function metrics = getDigraphMetrics(G)

    % compute metrics of directed network
    
    % in/outdegree centrality
    metrics.C_indegree = centrality(G, 'indegree', ...
        'Importance', G.Edges.Weight);
    metrics.C_outdegree = centrality(G, 'outdegree', ...
        'Importance', G.Edges.Weight);
    
    % in/outcloseness centrality
    metrics.C_incloseness = centrality(G, 'incloseness', ...
        'Cost', G.Edges.Weight);
    metrics.C_outcloseness = centrality(G, 'outcloseness', ...
        'Cost', G.Edges.Weight);
    
    % betweenness centrality
    metrics.C_betweenness = centrality(G, 'betweenness', ...
        'Cost', G.Edges.Weight);
    
    % pagerank centrality
    metrics.C_pagerank = centrality(G, 'pagerank', ...
        'Importance', G.Edges.Weight);
    
    % hubs and authorities
    metrics.C_hubs = centrality(G, 'hubs', ...
        'Importance', G.Edges.Weight);
    metrics.C_authorities = centrality(G, 'authorities', ...
        'Importance', G.Edges.Weight);
    
    
    