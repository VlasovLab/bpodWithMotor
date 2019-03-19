function wallNwater
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
  
    for trial = 1:trials
        fprintf('Trial %d...\n', trial);
        fprintf('Now executing pattern %d...\n', randomList(trial));
        sma = NewStateMachine();
        sma = AddState(sma, 'Name', 'WallMovement', ...
            'Timer', 1,...
            'StateChangeConditions', {'Tup', 'WallStop'},...
            'OutputActions', {'LED', 4, 'SoftCode', randomList(trial)});
        
        sma = AddState(sma, 'Name', 'WallStop', ...
            'Timer', 4,...
            'StateChangeConditions', {'Tup', 'WallBack'},...
            'OutputActions', {'LED', 4});
        
        sma = AddState(sma, 'Name', 'WallBack', ...
            'Timer', 1,...
            'StateChangeConditions', {'Tup', 'WaterSupply'},...
            'OutputActions', {'LED', 4, 'SoftCode', randomList(trial)+7});
        
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