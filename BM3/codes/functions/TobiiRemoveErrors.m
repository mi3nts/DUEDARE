% FUNCTION TO REMOVE ERROR VALUES FROM A TIMETABLE TOBII PRO GLASSES 2 DATA

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function Timetable = TobiiRemoveErrors(Timetable)

    %% CREATE ARRAYS FOR INDICIES WHERE ERRORS OCCUR

    % get error variables names 
    errorVarNames = ...
        Timetable.Properties.VariableNames([1 6 11 14 17 22 27 32 40 44])';

    % get indicies bad records for for each error variable
    for i=1:10
        % round up error values in ith column
        eval(strcat("Timetable.", errorVarNames(i) ,"=ceil(Timetable.", ...
            errorVarNames(i), ");"));
        
        % get records for ith error variable
        eval(strcat("errorRows", string(i)," = find(Timetable.",...
            errorVarNames(i)," ~= 0);"));
    end
    %% SET VALUES WITH ERROR AS NAN

    % Error_LeftPupilCenter_Timetable
    Timetable.GazeIndex_LeftPupilCenter_Timetable(errorRows1) = NaN;
    Timetable.PupilCenterX_LeftPupilCenter_Timetable(errorRows1) = NaN;
    Timetable.PupilCenterY_LeftPupilCenter_Timetable(errorRows1) = NaN;
    Timetable.PupilCenterZ_LeftPupilCenter_Timetable(errorRows1) = NaN;

    % Error_RightPupilCenter_Timetable
    Timetable.GazeIndex_RightPupilCenter_Timetable(errorRows2) = NaN;
    Timetable.PupilCenterX_RightPupilCenter_Timetable(errorRows2) = NaN;
    Timetable.PupilCenterY_RightPupilCenter_Timetable(errorRows2) = NaN;
    Timetable.PupilCenterZ_RightPupilCenter_Timetable(errorRows2) = NaN;

    % Error_LeftPupilDiameter_Timetable
    Timetable.GazeIndex_LeftPupilDiameter_Timetable(errorRows3) = NaN;
    Timetable.PupilDiameter_LeftPupilDiameter_Timetable(errorRows3) = NaN;

    % Error_RightPupilDiameter_Timetable
    Timetable.GazeIndex_RightPupilDiameter_Timetable(errorRows4) = NaN;
    Timetable.PupilDiameter_RightPupilDiameter_Timetable(errorRows4) = NaN;

    % Error_LeftGazeDirection_Timetable
    Timetable.GazeIndex_LeftGazeDirection_Timetable(errorRows5) = NaN;
    Timetable.GazeDirectionX_LeftGazeDirection_Timetable(errorRows5) = NaN;
    Timetable.GazeDirectionY_LeftGazeDirection_Timetable(errorRows5) = NaN;
    Timetable.GazeDirectionZ_LeftGazeDirection_Timetable(errorRows5) = NaN;

    % Error_RightGazeDirection_Timetable
    Timetable.GazeIndex_RightGazeDirection_Timetable(errorRows6) = NaN;
    Timetable.GazeDirectionX_RightGazeDirection_Timetable(errorRows6) = NaN;
    Timetable.GazeDirectionY_RightGazeDirection_Timetable(errorRows6) = NaN;
    Timetable.GazeDirectionZ_RightGazeDirection_Timetable(errorRows6) = NaN;

    % Error_GazePosition_Timetable
    Timetable.GazeIndex_GazePosition_Timetable(errorRows7) = NaN;
    Timetable.Latency(errorRows7) = NaN;
    Timetable.GazePositionX(errorRows7) = NaN;
    Timetable.GazePositionY(errorRows7) = NaN;

    % Error_GazePosition3D_Timetable
    Timetable.GazePosition3DX(errorRows8) = NaN;
    Timetable.GazePosition3DY(errorRows8) = NaN;
    Timetable.GazePosition3DZ(errorRows8) = NaN;

    % Error_Gyroscope_Timetable
    Timetable.GyroscopeX(errorRows9) = NaN;
    Timetable.GyroscopeY(errorRows9) = NaN;
    Timetable.GyroscopeZ(errorRows9) = NaN;

    % Error_Accelerometer_Timetable
    Timetable.AccelerometerX(errorRows10) = NaN;
    Timetable.AccelerometerY(errorRows10) = NaN;
    Timetable.AccelerometerZ(errorRows10) = NaN;
    
    