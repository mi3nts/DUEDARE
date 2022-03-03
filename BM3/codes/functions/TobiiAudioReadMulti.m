% FUNCTION TO READ AUDIO FROM MULTIPLE TOBII PRO GLASSES VIDEOS

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

% INPUTS
%     YEAR = STRING. ex:'2019';
%     MONTH = STRING. ex:'12';
%     DAY = STRING. ex:'5';
%     USER = STRING. ex:'U010';
%     Tobii = STRING. ex:'Tobii01';
%     TrialNumbers = ROW VECTOR OF INTEGERS IN ASCENDING ORDER1
%     saveStructure = ANY TYPE. 
%         IF USER WANTS TO SAVE OBJECT TO FILE, INPUT ANY TYPE. 
%         IF USER DOES NOT WANT TO SAVE OBJECT TO FILE USE '[]'

function [] = TobiiAudioReadMulti(YEAR, MONTH, DAY, USER, Tobii,...
    TrialNumbers)

 % iteratively read data files
for i=TrialNumbers

    % define trial name
    if i<9
        TRIAL = strcat('T0', string(i));
    else
        TRIAL = strcat('T', string(i));
    end

    % read respective tobii data file and save object to file
    TobiiAudioRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii);

    % display which trial was read
    disp(strcat("Trial ", string(i), " complete"))

end

% clear TobiiAudio structure
clear TobiiAudio