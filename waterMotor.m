function waterMotor
    global BpodSystem
    
    mouse = input('Enter the ID of the mouse: ');
    nth = input('Which time for this mouse? ');
    trials = input('How many trials? ');
    date = datetime('today', 'format', 'yyyy-MM-dd');
    filename =  strcat('C:\Matlab\Data-WallMovement\', num2str(mouse), '_', num2str(nth), '_', datestr(date), '.csv');
    randomList = randi(7, 1, trials);
    %headers = {'Pattern', 'Left', 'Right', 'Veolocity'};
    order = (1:trials);
    distanceLeft = [15,35,35,35,5,10,15,35];
    distanceRight = [15,5,10,15,35,35,35,35];
    velocitySet = [50,35,28,22,35,28,22];
    list = [order', randomList', distanceLeft(randomList)', distanceRight(randomList)', velocitySet(randomList)'];
    csvwrite(filename, list);
  
    A = BpodAnalogIn('COM3');
    myChannel = 1;
    A.Thresholds(myChannel) = 2.5;
    A.ResetVoltages(myChannel) = 1;
    A.SMeventsEnabled(myChannel) = 1;
    A.startReportingEvents();

    W = BpodWavePlayer('COM9');
    W.SamplingRate = 2000;
    W.OutputRange = '0V:5V';
    W.TriggerProfiles(:,:) = 1;
    wave5 = 5*ones(1,10);
    W.loadWaveform(2, wave5);
    %W.BpodEvents{1} = 'On';
    %W.TriggerProfileEnable = 'On';
    W.TriggerMode = 'Master';
    
    LoadSerialMessages('AnalogIn1',   {['E' 1 1]});
    LoadSerialMessages('WavePlayer1', {['P' 1 1]}); % 'WavePlayer1', 1
    LoadSerialMessages('WavePlayer1', {['P' 2]});
    
    sma = NewStateMachine();
    sma = SetGlobalTimer(sma, 'TimerID', 1, 'Duration', 5); % 'OutputActions', {'GlobalTimerTrig', 1}   'StateChangeConditions', {'GlobalTimer1_End', 'exit'}
    for trial = 1:trials
        fprintf('Trial %d...\n', trial);
        fprintf('Now executing pattern %d...\n', randomList(trial));
        
        
        sma = AddState(sma, 'Name', 'Initialization', ...
            'Timer', 1,...
            'StateChangeConditions', {'Tup', 'WFwd'},...
            'OutputActions', {'SoftCode', -1}); % Change wall direction
        
        sma = AddState(sma, 'Name', 'WFwd', ...
            'Timer', 0.5,...
            'StateChangeConditions', {'Tup', 'WKeep1'},...
            'OutputActions', {'WavePlayer1', 1}); % Arduino -> motor (trig2) forward
        
        sma = AddState(sma, 'Name', 'WKeepF1', ...
            'Timer', 0,...
            'StateChangeConditions', {'Tup', 'WKeepF2'},...
            'OutputActions', {'SoftCode', -2}); % Change wall direction -> forward
        
        sma = AddState(sma, 'Name', 'WKeepF2', ...
            'Timer', 0.1,...
            'StateChangeConditions', {'Tup', 'WKeepF1', 'AnalogIn1_1', 'WKeepB1', 'GlobalTimer1_End', 'WBwd1'},...
            'OutputActions', {'WavePlayer1', 2});
        
        sma = AddState(sma, 'Name', 'WKeepB1', ...
            'Timer', 0,...
            'StateChangeConditions', {'Tup', 'WKeepB2'},...
            'OutputActions', {'SoftCode', -2}); % Change wall direction -> backward
        
        sma = AddState(sma, 'Name', 'WKeepB2', ...
            'Timer', 0.1,...
            'StateChangeConditions', {'Tup', 'WKeepB1', 'AnalogIn1_2', 'WKeepF1', 'GlobalTimer1_End', 'WBwd1'},...
            'OutputActions', {'SoftCode', -3, });
        
        sma = AddState(sma, 'Name', 'WBwd1', ...
            'Timer', 1,...
            'StateChangeConditions', {'Tup', 'WBwd2'},...
            'OutputActions', {'SoftCode', -2});
        
        sma = AddState(sma, 'Name', 'WFwd', ...
            'Timer', 0.5,...
            'StateChangeConditions', {'Tup', 'WKeep1'},...
            'OutputActions', {'WavePlayer1', 1}); % Arduino -> motor (trig2) forward
        
        sma = AddState(sma, 'Name', 'WaterSupply', ... % state 4 is generating water drop signsl on BNC channel 1
            'Timer', 1,... %water dropping time
            'StateChangeConditions', {'Tup', 'Restart'},...
            'OutputActions', {'LED', 3}); %LED Channel output channel "1" to 3.3V (high)until state change

        sma = AddState(sma, 'Name', 'Restart', ...
            'Timer', 1,...
            'StateChangeConditions', {'Tup', 'exit'},... 
            'OutputActions', {});  
        
        BpodSystem.SoftCodeHandlerFunction = 'soft2wall';
        SendStateMachine(sma);
        RawEvents = RunStateMachine;
    end