% FUNCTION FUNCTION TO LOAD VIDEO HANDLE RECORDED BY TOBII PRO GLASSES 2

% INPUTS:
%     inputPath = PATH TO VIDEO FILES
%     videoName = FILENAME WITHOUT FILE TYPE OF VIDEO
% 
% OUTPUT:
%     v = video handle

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function v = getTobiiVideo(inputPath,videoName)

    % if running on Linux system use .avi format
    if strcmp(computer, 'GLNXA64')

        % check if .avi video exists
        if ~exist(strcat(inputPath, videoName, '.avi'), 'file')

            % if it does not, convert mp4 to avi
            TobiiMp4ToAvi(inputPath, videoName);

        end

        % read video
        v = VideoReader(strcat(inputPath, videoName, '.avi'));

    % if running on MAC or Windows system use .mp4 format
    else
        % read video
        v = VideoReader(strcat(inputPath, videoName, '.mp4'));
    end
end