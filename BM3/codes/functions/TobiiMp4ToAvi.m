% FUNCTION TO CONVERT TOBII POV VIDEO MP4 TO AVI USING FFMPEG

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = TobiiMp4ToAvi(inputPath, videoName)

    % grab current path
    homePath = pwd;

    % check if running on MAC system
    if strcmp(computer, 'MACI64')
        % set environment path to include libraries in bin
        % NOTE: it is important that ffmpeg is saved to bin!
        % Likely need to hack to get working on Windows OS!
        setenv('PATH', '/usr/local/bin/');
    end
   
    % change dir to folder with video
    eval(strcat("cd ", inputPath))

    % convert video from mp4 to avi using ffmpeg
    if strcmp(videoName, 'fullstream')
        !ffmpeg -i fullstream.mp4 -c:v mjpeg fullstream.avi
    elseif strcmp(videoName, 'eyesstream')
        !ffmpeg -i eyesstream.mp4 -c:v mjpeg eyesstream.avi
    end

    % change dir to orginal folder
    eval(strcat("cd ", homePath))

end 