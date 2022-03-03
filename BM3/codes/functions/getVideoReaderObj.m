% FUNCTION TO LOAD VIDEO READER OBJECT  FROM FILE FOR TOBII PRO GLASSES 2 
% SYSTEM

% INPUTS:

%     pathID = STRING. path of file
%     ID = STRING. ID of dataset
%     Tobii = STRING. Tobii device ID

% OUTPUTS:
% 
%     v = video object

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)


function v = getVideoReaderObj(pathID, ID, Tobii)

    % define path to tobii pov video
    inputPath = strcat('raw/',pathID, '/', Tobii, '/', ...
            ID, '_', Tobii, '/segments/1/');

    % if running on Linux system use .avi format
    if strcmp(computer, 'GLNXA64')

        % check if .avi video exists
        if ~exist(strcat(inputPath,'fullstream.avi'), 'file')

            % if it does not, convert mp4 to avi
            TobiiMp4ToAvi(inputPath);

        end

        % read video
        v = VideoReader(strcat(inputPath,'fullstream.avi'));

    % if running on MAC or Windows system use .mp4 format
    else
        % read video
        v = VideoReader(strcat('raw/',pathID, '/', Tobii, '/', ...
            ID, '_', Tobii, '/segments/1/fullstream.mp4'));
    end
    
end