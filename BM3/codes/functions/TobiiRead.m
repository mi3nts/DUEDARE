% FUNCTION TO READ DATA FROM LIVEDATA.JSON FILE FOR TOBII PRO GLASSES 2

% INPUTS:
%     YEAR = STRING
%     MONTH = STRING
%     DAY = STRING
%     TRIAL = STRING
%     USER = STRING
%     Tobii = STRING. NUMBER OF TOBII SYSTEM USED

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

% ------------------------------------------------------------------------- 
function[] = TobiiRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii)

    % change number format to long
    format long

    % get ID
    [ID, ~] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, Tobii);

    % define path of data json file 

    % windows case
    if contains(computer, 'WIN')
        seperator = '\';

    % mac and linux case
    else
        seperator = '/';
    end

    % define pathID
    pathID = strrep(ID,'_',seperator);

    % define path of folder with tobii data
    dataFolderName = strcat('raw', seperator, ...
        pathID,seperator, ...
        ID,seperator, ...
        'segments',seperator,...
        '1',seperator);

    % check if livedata.json file exists, if not uncompress it
    if ~exist(strcat(dataFolderName,'livedata.json'), 'file')

        gunzip(strcat(dataFolderName,'livedata.json.gz'), dataFolderName)
    end

    % read segment .json file
    string1 = fileread(strcat(dataFolderName, 'segment.json'));

    % decode segment.json file
    string_decoded = jsondecode(string1);

    % get date and time info and create duration objects
    start_datetime = string_decoded.seg_t_start;
    start_date = datetime(start_datetime(1:10), 'InputFormat', 'yyyy-MM-dd');
    start_time = duration(start_datetime(12:19),'format','hh:mm:ss.SSSS');

    stop_datetime = string_decoded.seg_t_stop;
    stop_date = datetime(stop_datetime(1:10), 'InputFormat', 'yyyy-MM-dd');
    stop_time = duration(stop_datetime(12:19),'format','hh:mm:ss.SSSS');

    % define duration object for elapsed time
    elapsed_time = (stop_date+stop_time) - (start_date+start_time);

    % open livedata file
    file = fopen(strcat(dataFolderName,'livedata.json'));

    % DEFINE VARIABLE NAMES FOR TABLES BASED ON EVERY POSSIBLE LINE TYPE

    % variable names of pupil center tables (6 vars) (5 fields)
    NamesPC = {'Datetime', 'Error', 'GazeIndex', 'PupilCenterX',...
        'PupilCenterY', 'PupilCenterZ'};

    % variable names of pupil diameter tables (4 vars) (5 fields)
    NamesPD = {'Datetime', 'Error', 'GazeIndex', 'PupilDiameter'};

    % variable names of gaze direction tables (6 vars) (5 fields)
    NamesGD = {'Datetime', 'Error', 'GazeIndex', 'GazeDirectionX', ...
        'GazeDirectionY', 'GazeDirectionZ'};

    % variable names of gaze position table (6 vars) (5 fields)
    NamesGP = {'Datetime', 'Error', 'GazeIndex', 'Latency', 'GazePositionX', ...
        'GazePositionY'};

    % variable names of API-sync package table (5 vars) (5 fields)
    NamesAPI = {'Datetime', 'Error', 'EventDatetime', 'Type', 'Tag'}; 

    % variable names of 3D gaze position table (6 vars) (4 fields)
    NamesGP3D = {'Datetime', 'Error', 'GazeIndex', 'GazePosition3DX',...
        'GazePosition3DY', 'GazePosition3DZ'};

    % variable names of sync port signal package table (4 vars) (4 fields)
    NamesSyncPort = {'Datetime', 'Error', 'Direction', 'Signal'};

    % variable names of presentation Datetime sync package table (4 vars) (4 fields)
    NamesPTS = {'Datetime', 'PresentationDatetime', 'PipelineVersion','Error'};

    % variable names of gyroscope table (5 vars) (3 fields)
    NamesGyro = {'Datetime', 'GyroscopeX', 'GyroscopeY', 'GyroscopeZ', 'Error'};

    % variable names of accelerometer table (5 vars) (3 fields)
    NamesAccel = {'Datetime', 'AccelerometerX', 'AccelerometerY',...
        'AccelerometerZ', 'Error'};

    % variable names of video Datetime sync package table (3 vars) (3 fields)
    NamesVTS = {'Datetime', 'VideoDatetime','Error'};

    % variable names of eye camera video Datetime sync package table (3 vars) (3 fields)
    NamesEVTS = {'Datetime', 'Error', 'EyeVideoTimestamp'};


    initial3 = {NaN NaN NaN};
    initial4 = {NaN NaN NaN NaN};
    initial5 = {NaN NaN NaN NaN NaN};
    initial6 = {NaN NaN NaN NaN NaN NaN};

    % TobiiTable = cell2table(initial,'VariableNames',Names);

    % INTIALIZE TABLES
    LeftPupilCenter_Table = cell2table(initial6, 'VariableNames', NamesPC);
    RightPupilCenter_Table = cell2table(initial6, 'VariableNames', NamesPC);
    LeftPupilDiameter_Table = cell2table(initial4, 'VariableNames', NamesPD);
    RightPupilDiameter_Table = cell2table(initial4, 'VariableNames', NamesPD);
    LeftGazeDirection_Table = cell2table(initial6, 'VariableNames', NamesGD);
    RightGazeDirection_Table = cell2table(initial6, 'VariableNames', NamesGD);
    GazePosition_Table = cell2table(initial6, 'VariableNames', NamesGP);
    GazePosition3D_Table = cell2table(initial6, 'VariableNames', NamesGP3D);
    Gyroscope_Table = cell2table(initial5, 'VariableNames', NamesGyro);
    Accelerometer_Table = cell2table(initial5, 'VariableNames', NamesAccel);
    PTS_Table = cell2table(initial4, 'VariableNames', NamesPTS);
    VTS_Table = cell2table(initial3, 'VariableNames', NamesVTS);
    EVTS_Table = cell2table(initial3, 'VariableNames', NamesEVTS);
    Sync_Table = cell2table(initial4, 'VariableNames', NamesSyncPort);
    API_Table = cell2table(initial5, 'VariableNames', NamesAPI);

    % INTIALIZE TABLE COUNTERS
    LeftPupilCenter_counter = 1;
    RightPupilCenter_counter = 1;
    LeftPupilDiameter_counter = 1;
    RightPupilDiameter_counter = 1;
    LeftGazeDirection_counter = 1;
    RightGazeDirection_counter = 1;
    GazePosition_counter = 1;
    GazePosition3D_counter = 1;
    Gyroscope_counter = 1;
    Accelerometer_counter = 1;
    PTS_counter = 1;
    VTS_counter = 1;
    EVTS_counter = 1;
    Sync_counter = 1;
    API_counter = 1;

    % read each line of the file loop
    while feof(file)==0

        line = fgetl(file);
        line_decoded = jsondecode(line);
        field_names = fieldnames(line_decoded);

        switch length(field_names)

            % evaluate case of 5 field names. (LeftPC, RightPC, LeftPD,
            % RightPD, LeftGD, RightGD, GP, API)
            case 5
                %disp(5)
                last_field = field_names(5,1);

                % evaluate if line contains field 'eye'. (LeftPC, RightPC,
                % LeftPD, RightPD, LeftGD, RightGD)
                if strcmp(last_field, 'eye')
                    field4 = field_names(4,1);

                    % evaluate if 'eye' field is = left. (LeftPC, LeftPD, LeftGD)
                    if strcmp(line_decoded.eye, 'left')

                        % evaluate if line contains 'pc'. (LeftPC)
                        if strcmp(field4, 'pc')

                            tempRow = {(line_decoded.ts * 10^-6) line_decoded.s...
                                 line_decoded.gidx line_decoded.pc(1)...
                                 line_decoded.pc(2) line_decoded.pc(3)};

                            LeftPupilCenter_Table(LeftPupilCenter_counter,:) ...
                                = tempRow;

                            LeftPupilCenter_counter = LeftPupilCenter_counter + 1;

                        % evaluate if line contains 'pd'. (LeftPD)
                        elseif strcmp(field4, 'pd')

                            tempRow = {(line_decoded.ts * 10^-6) line_decoded.s ...
                                line_decoded.gidx line_decoded.pd};

                            LeftPupilDiameter_Table(LeftPupilDiameter_counter,:) ...
                                = tempRow;

                            LeftPupilDiameter_counter = LeftPupilDiameter_counter + 1;

                        % evaluate if line contains 'gd'. (LeftGD)
                        elseif strcmp(field4, 'gd')

                            tempRow = {(line_decoded.ts * 10^-6) line_decoded.s line_decoded.gidx...
                                line_decoded.gd(1) line_decoded.gd(2) line_decoded.gd(3)};

                            LeftGazeDirection_Table(LeftGazeDirection_counter,:) ...
                                = tempRow;

                            LeftGazeDirection_counter = LeftGazeDirection_counter + 1;

                        end
                    end

                    % evaluate if 'eye' field is = left. (RightPC, RightPD, RightGD)
                    if strcmp(line_decoded.eye, 'right')

                        % evaluate if line contains 'pc'. (RightPC)
                        if strcmp(field4, 'pc')

                            tempRow = {(line_decoded.ts * 10^-6) line_decoded.s...
                                 line_decoded.gidx line_decoded.pc(1)...
                                 line_decoded.pc(2) line_decoded.pc(3)};

                            RightPupilCenter_Table(RightPupilCenter_counter,:) ...
                                = tempRow;

                            RightPupilCenter_counter = RightPupilCenter_counter + 1;

                        % evaluate if line contains 'pd'. (RightPD)
                        elseif strcmp(field4, 'pd')

                            tempRow = {(line_decoded.ts * 10^-6) line_decoded.s ...
                                line_decoded.gidx line_decoded.pd};

                            RightPupilDiameter_Table(RightPupilDiameter_counter,:) ...
                                = tempRow;

                            RightPupilDiameter_counter = RightPupilDiameter_counter + 1;

                        % evaluate if line contains 'gd'. (RightGD)
                        elseif strcmp(field4, 'gd')

                            tempRow = {(line_decoded.ts * 10^-6) line_decoded.s line_decoded.gidx...
                                line_decoded.gd(1) line_decoded.gd(2) line_decoded.gd(3)};

                            RightGazeDirection_Table(RightGazeDirection_counter,:) ...
                                = tempRow;

                            RightGazeDirection_counter = RightGazeDirection_counter + 1;
                        end

                    end

                % evaluate if line contains field 'gp' (GP)
                elseif strcmp(last_field, 'gp')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.s line_decoded.gidx...
                        line_decoded.l line_decoded.gp(1) line_decoded.gp(2)};

                    GazePosition_Table(GazePosition_counter, :) = tempRow;

                    GazePosition_counter = GazePosition_counter + 1;

                % evaluate if line contains field 'tag' (API)
                elseif strcmp(last_field, 'tag')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.s line_decoded.ets...
                        string(line_decoded.type) string(line_decoded.tag)};

                    API_Table(API_counter,:) = tempRow;

                    API_counter = API_counter + 1;

                end

            % evaluate case of 4 field names. (GP3D, SYNC, PTS) 
            case 4
                last_field = field_names(4,1);

                % evaluate if line contains field 'gp3' (GP3D)
                if strcmp(last_field, 'gp3')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.s line_decoded.gidx...
                        line_decoded.gp3(1) line_decoded.gp3(2) line_decoded.gp3(3)};

                    GazePosition3D_Table(GazePosition3D_counter,:) = tempRow;

                    GazePosition3D_counter = GazePosition3D_counter + 1;

                % evaluate if line contains field 'sig' (SYNC)
                elseif strcmp(last_field, 'sig')

                    if strcmp(line_decoded.dir, 'in')
                        tempDir = 1;
                    elseif strcmp(line_decoded.dir, 'out')
                        tempDir = 0;
                    end

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.s ...
                        tempDir line_decoded.sig};

                    Sync_Table(Sync_counter,:) = tempRow;

                    Sync_counter = Sync_counter + 1;

                % evaluate if line contains field 's' (PTS)    
                elseif strcmp(last_field, 's')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.pts line_decoded.pv...
                        line_decoded.s};

                    PTS_Table(PTS_counter,:) = tempRow;

                    PTS_counter = PTS_counter + 1;

                end

            % evaluate case of 3 field names. (Gyro, Accel, VTS, EVTS)     
            case 3
                field2 = field_names(2,1);
                field3 = field_names(3,1);

                % evaluate if line contains field 'gy' (Gyro) 
                if strcmp(field2,'gy') || strcmp(field3,'gy')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.gy(1)...
                        line_decoded.gy(2) line_decoded.gy(3) line_decoded.s};

                    Gyroscope_Table(Gyroscope_counter,:) = tempRow;

                    Gyroscope_counter = Gyroscope_counter + 1;

                % evaluate if line contains field 'ac' (Accel)
                elseif strcmp(field2,'ac') || strcmp(field3,'ac')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.ac(1)...
                        line_decoded.ac(2) line_decoded.ac(3) line_decoded.s};

                    Accelerometer_Table(Accelerometer_counter,:) = tempRow;

                    Accelerometer_counter = Accelerometer_counter + 1;

                % evaluate if line contains field 'vts' (VTS)    
                elseif strcmp(field2,'vts') || strcmp(field3,'vts')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.vts line_decoded.s};

                    VTS_Table(VTS_counter,:) = tempRow;

                    VTS_counter = VTS_counter + 1;

                % evaluate if 2nd field is 's' (EVTS)   
                elseif strcmp(field2,'evts') || strcmp(field3,'evts')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.evts line_decoded.s};

                    EVTS_Table(EVTS_counter,:) = tempRow;

                    EVTS_counter = EVTS_counter + 1;

                end

        end

    end 
    % end of read each line of the file loop

    % CONVERT Datetime COLUMNS TO DURATION objects 

    LeftPupilCenter_Table.Datetime = seconds(LeftPupilCenter_Table.Datetime);
    RightPupilCenter_Table.Datetime = seconds(RightPupilCenter_Table.Datetime);
    LeftPupilDiameter_Table.Datetime = seconds(LeftPupilDiameter_Table.Datetime);
    RightPupilDiameter_Table.Datetime = seconds(RightPupilDiameter_Table.Datetime);
    LeftGazeDirection_Table.Datetime = seconds(LeftGazeDirection_Table.Datetime);
    RightGazeDirection_Table.Datetime = seconds(RightGazeDirection_Table.Datetime);
    GazePosition_Table.Datetime = seconds(GazePosition_Table.Datetime);
    GazePosition3D_Table.Datetime = seconds(GazePosition3D_Table.Datetime);
    Gyroscope_Table.Datetime = seconds(Gyroscope_Table.Datetime);
    Accelerometer_Table.Datetime = seconds(Accelerometer_Table.Datetime);
    PTS_Table.Datetime = seconds(PTS_Table.Datetime);
    VTS_Table.Datetime = seconds(VTS_Table.Datetime);
    EVTS_Table.Datetime = seconds(EVTS_Table.Datetime);
    Sync_Table.Datetime = seconds(Sync_Table.Datetime);
    API_Table.Datetime = seconds(API_Table.Datetime);

    % COMPUTE MIN Datetime VALUES FOR EACH TABLE

    minDatetimeValues = [min(LeftPupilCenter_Table.Datetime); ...
        min(RightPupilCenter_Table.Datetime); ...
        min(LeftPupilDiameter_Table.Datetime); ...
        min(RightPupilDiameter_Table.Datetime); ...
        min(LeftGazeDirection_Table.Datetime); ...
        min(RightGazeDirection_Table.Datetime); ...
        min(GazePosition_Table.Datetime); ...
        min(GazePosition3D_Table.Datetime); ...
        min(Gyroscope_Table.Datetime); ...
        min(Accelerometer_Table.Datetime); ...
        min(PTS_Table.Datetime); ...
        min(VTS_Table.Datetime); ...
        min(EVTS_Table.Datetime); ...
        min(Sync_Table.Datetime); ...
        min(API_Table.Datetime)];

    minDatetime = min(minDatetimeValues);

    % SUBTRACT LOWEST Datetime VALUE FROM ALL DatetimeS AND ADD START TIME

    LeftPupilCenter_Table.Datetime = start_date + start_time + ...
        LeftPupilCenter_Table.Datetime - minDatetime;
    RightPupilCenter_Table.Datetime = start_date + start_time + ... 
        RightPupilCenter_Table.Datetime - minDatetime;
    LeftPupilDiameter_Table.Datetime = start_date + start_time + ... 
        LeftPupilDiameter_Table.Datetime - minDatetime;
    RightPupilDiameter_Table.Datetime = start_date + start_time + ... 
        RightPupilDiameter_Table.Datetime - minDatetime;
    LeftGazeDirection_Table.Datetime = start_date + start_time + ... 
        LeftGazeDirection_Table.Datetime - minDatetime;
    RightGazeDirection_Table.Datetime = start_date + start_time + ... 
        RightGazeDirection_Table.Datetime - minDatetime;
    GazePosition_Table.Datetime = start_date + start_time +...
        GazePosition_Table.Datetime - minDatetime;
    GazePosition3D_Table.Datetime = start_date + start_time + ...
        GazePosition3D_Table.Datetime - minDatetime;
    Gyroscope_Table.Datetime = start_date + start_time + ...
        Gyroscope_Table.Datetime - minDatetime;
    Accelerometer_Table.Datetime = start_date + start_time + ...
        Accelerometer_Table.Datetime - minDatetime;
    PTS_Table.Datetime = start_date + start_time + PTS_Table.Datetime ...
        - minDatetime;
    VTS_Table.Datetime = start_date + start_time + VTS_Table.Datetime ...
        - minDatetime;
    EVTS_Table.Datetime = start_date + start_time + EVTS_Table.Datetime ...
        - minDatetime;
    Sync_Table.Datetime = start_date + start_time + Sync_Table.Datetime ...
        - minDatetime;
    API_Table.Datetime = start_date + start_time + API_Table.Datetime ...
        - minDatetime;

    % change default datetime format
    datetime.setDefaultFormats('default', 'dd-MMM-uuuu HH:mm:ss.SSSS');


    % SORT TABLES BY Datetime

    LeftPupilCenter_Table = sortrows(LeftPupilCenter_Table);
    RightPupilCenter_Table = sortrows(RightPupilCenter_Table);
    LeftPupilDiameter_Table = sortrows(LeftPupilDiameter_Table);
    RightPupilDiameter_Table = sortrows(RightPupilDiameter_Table);
    LeftGazeDirection_Table = sortrows(LeftGazeDirection_Table);
    RightGazeDirection_Table = sortrows(RightGazeDirection_Table);
    GazePosition_Table = sortrows(GazePosition_Table);
    GazePosition3D_Table = sortrows(GazePosition3D_Table);
    Gyroscope_Table = sortrows(Gyroscope_Table);
    Accelerometer_Table = sortrows(Accelerometer_Table);
    PTS_Table = sortrows(PTS_Table);
    VTS_Table = sortrows(VTS_Table);
    EVTS_Table = sortrows(EVTS_Table);
    Sync_Table = sortrows(Sync_Table);
    API_Table = sortrows(API_Table);


    % CONVERT TABLES TO TIMETABLES

    LeftPupilCenter_Timetable = table2timetable(LeftPupilCenter_Table);
    RightPupilCenter_Timetable = table2timetable(RightPupilCenter_Table);
    LeftPupilDiameter_Timetable = table2timetable(LeftPupilDiameter_Table);
    RightPupilDiameter_Timetable= table2timetable(RightPupilDiameter_Table);
    LeftGazeDirection_Timetable= table2timetable(LeftGazeDirection_Table);
    RightGazeDirection_Timetable = table2timetable(RightGazeDirection_Table);
    GazePosition_Timetable = table2timetable(GazePosition_Table);
    GazePosition3D_Timetable = table2timetable(GazePosition3D_Table);
    Gyroscope_Timetable = table2timetable(Gyroscope_Table);
    Accelerometer_Timetable = table2timetable(Accelerometer_Table);
    PTS_Timetable = table2timetable(PTS_Table);
    VTS_Timetable = table2timetable(VTS_Table);
    EVTS_Timetable = table2timetable(EVTS_Table);
    Sync_Timetable = table2timetable(Sync_Table);
    API_Timetable = table2timetable(API_Table);

    % CREATE ARRAY OF TIMETABLE NAMES
    timetables = ["LeftPupilCenter_Timetable" "RightPupilCenter_Timetable" ...
        "LeftPupilDiameter_Timetable" "RightPupilDiameter_Timetable" ...
        "LeftGazeDirection_Timetable" "RightGazeDirection_Timetable" ...
        "GazePosition_Timetable" "GazePosition3D_Timetable" ...
        "Gyroscope_Timetable" "Accelerometer_Timetable"...
        "PTS_Timetable" "VTS_Timetable" "EVTS_Timetable" ...
        "Sync_Timetable" "API_Timetable"];


    % CHECK IF TIMETABLES HAVE DATA NaT, IF SO REPLACE WITH START DATETIME
    for timetable = timetables
        eval(strcat("bool = sum(isnat(",timetable,".Datetime));"));

        % check if Datetime is not a time
        if bool 
            % if not a time replace it with data start datetime
            eval(strcat(timetable, ".Datetime = start_date + start_time;"));
        end

    end



    % SYNCRONIZE TIMETABLES

    % create timetable that with tobii data suitable for analysis
    try
        TobiiTimetable = synchronize(...
            LeftPupilCenter_Timetable, RightPupilCenter_Timetable, ...
            LeftPupilDiameter_Timetable, RightPupilDiameter_Timetable, ...
            LeftGazeDirection_Timetable, RightGazeDirection_Timetable, ...
            GazePosition_Timetable, GazePosition3D_Timetable, ...
            Gyroscope_Timetable, Accelerometer_Timetable, ...
            'regular','linear','TimeStep', milliseconds(10));
    catch
        % ENSURE TIMETABLES HAVE UNIQUE DATETIMES
        for timetable = timetables
            eval(strcat(timetable," = retime(",timetable,...
                ",unique(",timetable,".Datetime),'mean');"));
        end

        TobiiTimetable = synchronize(...
            LeftPupilCenter_Timetable, RightPupilCenter_Timetable, ...
            LeftPupilDiameter_Timetable, RightPupilDiameter_Timetable, ...
            LeftGazeDirection_Timetable, RightGazeDirection_Timetable, ...
            GazePosition_Timetable, GazePosition3D_Timetable, ...
            Gyroscope_Timetable, Accelerometer_Timetable, ...
            'regular','linear','TimeStep', milliseconds(10));
    end

    % create timetable that with raw tobii data for later synchronization
    rawTobiiTimetable = synchronize(...
        LeftPupilCenter_Timetable, RightPupilCenter_Timetable, ...
        LeftPupilDiameter_Timetable, RightPupilDiameter_Timetable, ...
        LeftGazeDirection_Timetable, RightGazeDirection_Timetable, ...
        GazePosition_Timetable, GazePosition3D_Timetable, ...
        Gyroscope_Timetable, Accelerometer_Timetable, ...
        PTS_Timetable, VTS_Timetable, EVTS_Timetable, ...
        Sync_Timetable, API_Timetable);

     % -------------------------------------------------------------------------
    % Remove values with errors
    % -------------------------------------------------------------------------
    TobiiTimetable = TobiiRemoveErrors(TobiiTimetable);

    % -------------------------------------------------------------------------
    % Compute and append additional pupil and gaze variables
    % -------------------------------------------------------------------------
    TobiiTimetable = getAllTobiiVars(TobiiTimetable);

    % -------------------------------------------------------------------------
    % Save objects 
    % -------------------------------------------------------------------------
    % create strings for TobiiTimetable and rawTobiiTimetable
    objectName = 'TobiiTimetable';
    rawName = 'rawTobiiTimetable';

    % get path string for each file
    objectPath = getFilePath('objects', ID, objectName);
    rawPath = getFilePath('raw', ID, rawName);

    % save timetables
    save(objectPath, objectName)
    save(rawPath, rawName)