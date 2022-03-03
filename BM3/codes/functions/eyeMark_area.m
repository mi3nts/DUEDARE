% FUNCTION TO COMPUTE AREA ENCLOSED BY EYEMARKS

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

% INPUT:
%     landmarks = LOCATION OF EYE LANDMARKS IN PIXEL COORDINATE SYSTEM

% OUTPUT:
%     areas = 2 ELEMENT ARRAY WITH RIGHT AND LEFT EYE AREAS RESPECTIVELY
%     marks = REORDERED EYE LANDMARKS FIRST 5 ELEMENTS CORRESPOND TO RIGHT
%     EYE AND LAST 6 ELEMENTS TO LEFT EYE


function [areas, marks] = eyeMark_area(landmarks)

    % define array of indicies to shuffle landmark order
    ishuffle = [1 3 4 2 5 6];

    % define right eye landmarks in cyclic order
    rmarks=landmarks(1:6,:);
    rmarks = rmarks(ishuffle,:);

    % define left eye landmarks in cyclic order
    lmarks = landmarks(7:end,:);
    lmarks = lmarks(ishuffle,:);

    % compute right and left eye areas
    rarea = polyarea(rmarks(:,1),rmarks(:,2));
    larea = polyarea(lmarks(:,1),lmarks(:,2));
    
    % define outputs
    areas = [rarea larea];
    marks = [rmarks; lmarks];