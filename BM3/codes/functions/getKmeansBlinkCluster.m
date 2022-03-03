% FUNCTION TO LABEL BLINKS USING MINIMUM DISTANCE TO KMEANS CLUSTERING 
% CENTROIDS ON EYE IMAGES COLLECTED WITH TOBII PRO GLASSES 2 

% INPUTS:
%     img = GRAYSCALE IMAGE OBJECT. 960×240x1.
%     C = CENTROIDS FOR EACH KMEANS CLUSTER (E.G. EYE CLOSED, OPEN,
%     PARTIAL, ETC.)
%     bias = NUMERICAL ARRAY. MANUAL BIAS TO PUSH POINT IN PIXEL SPACE
%     TOWARD A GIVEN CLUSTER. NOTE: POSITIVE VALUES "PUSH" POINT CLOSER AND
%     NEGATIVE VALUES "REPEL" POINT AWAY FROM CLUSTERS.

% NOTE: Heuristic to get which centroid corresponds to eyes closed or open
% or other. Sum centroid coordinates in grayscale pixel space. Larger sums 
% correspond to eyes open since the scelera is white.

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [clusterNumber, distanceMatrix] = getKmeansBlinkCluster(img, C, bias)

    % reshape image array to be 1D
    X = reshape(double(img), [1 960*240]);
    % get shape of centroid matrix
    [sz1, ~] = size(C);

    % initialize matrix of distances between input image and centroids
    distanceMatrix = zeros(1, sz1);

    % compute distances between input image and centroids
    for i = 1:sz1

        distanceMatrix(i) = norm(C(i,:)-X);

    end
    
    % apply bias vector to distance matrix
    distanceMatrix = distanceMatrix-bias; 

    % get cluster number
    [~, clusterNumber] = min(distanceMatrix);