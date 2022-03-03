% FUNCTION TO CALL PYTHON EYE MARK MODULE

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

% INPUT:
%     im = GRAYSCALE IMAGE FROM TOBII PRO GLASSES 2 EYESTREAM VIDEO 

% OUTPUT:
%     landmarks = LOCATION OF EYE LANDMARKS IN PIXEL COORDINATE SYSTEM

%     separations = ARRAY OF VARIOUS EYE SEPARATIONS. FIRST ROW IS A SCALED
%     SEPARATION OF THE RIGHT AND LEFT EYE RESPECTIVELY. SECOND ROW IS RAW
%     PIXEL HEIGHT OF EYELIDS. THRID ROW IS RAW PIXEL LENGTH OF EYES.

function [landmarks, separations] = eyeMark(im)

    cd backend/eyeMark

    % create python environment
    % NOTE: only needed when calling function first time
    try
        pyenv('Version', '/Users/shawhin/opt/anaconda3/bin/python');
    catch
    end

    % add current directory to python path if not already added
    if count(py.sys.path,'') == 0
        insert(py.sys.path,int32(0),'');
    end

    % create numpy version of image
    im_numpy = py.numpy.array(im);

    % call function
    output = py.eyeMark.eyeMark(im_numpy);

    % create matlab variables for eye landmarks and separations
    landmarks = double(output{1});
    separations = double(output{2});
    
    % change to home directory
    homeDir()


