function theData = MMT_eeg_study(thePath,listName,startTrial,testing)

% Run the Endo/Exo attention and subs memory expt. (MU3)
% Example use:
%  theData = MMT_eeg_study(thePath,'fMMT001_study1',1)
% written by Melina Uncapher 4/21/08, 
% adapted from fMRI to EEG by Anna Khazenzon 7/23/15

if nargin == 3
    testing = 0;
end

if testing == 1
    comp = input('Which computer? WendyO [1], Anna laptop [2]: ');
    PsychDebugWindowConfiguration
    sName = 'tt';
    sNum = 1;
    sSess = 1;
else
    comp = 1;
end

while 1
    scanner = input('practice laptop [1], practice fmri [2], fmri [3], eeg [4]? ');
    % Set input device (keyboard or buttonbox)
    if scanner == 2 || scanner == 3
        d = getBoxNumber;  % buttonbox
%         d = getBoxNumber_testing;  % buttonbox TESTING - PUT BACK PREVIOUS LINE PRIOR TO SCANNING!!!
        S.kbNum = getKeyboardNumber_Recca;
        break
    elseif scanner == 4
        S.kbNum = getEEGKeyboard;
        d = getKeyboardNumberWendyo;
        break
    elseif scanner == 1
        if comp == 1
            d = getKeyboardNumberWendyo;
        elseif comp == 2
            d = getKeyboardNumber_Anna;
        end
        break
    end
end

%% Input subject info:
if testing ~= 1
    sName = input('Enter subject initials: ','s');
    sNum = input('Enter subject number: ');
    sSess = input('Enter session number: ');
end
blinkType = input('Enter blink screen type, rectangles [1] or text [2]: ');

%% Initialize screen:
if scanner == 2 || scanner == 3 || scanner == 4
    [Window,Rect] = MU3initializeScreen; %display on secondary monitor
elseif scanner == 1
    [Window,Rect] = MU3initializeScreen_laptop; %display on primary monitor
end    

S.on = 0;  % Screen hasn't been opened yet

% Screen commands
if S.on == 0
    if scanner == 2 || scanner == 3 || scanner == 4
        S.screenNumber = 1; % secondary monitor
    elseif scanner == 1
        S.screenNumber = 0; % primary monitor
    end
    S.screenColor = 0; % black screen
    S.textColor = 255;  % white text
    [S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow', S.screenColor, []);
end
    
%% create objects
% rects in which to place stim 
rectHeight(1) = 150;
rectWidth(1) = 150;

%UPPER LEFT, this displaces the box by half the size of the box (i.e., if box is 150x150, the bottom right corner will be 75x75 up and to left of fixation) 
stimRect1 = round([Rect(3)/2-(rectWidth(1)+40), Rect(4)/2-(rectHeight(1)+40),Rect(3)/2-40, Rect(4)/2-40]); 

%UPPER RIGHT, this displaces the box by half the size of the box (i.e., if box is 150x150, the bottom left corner will be 75x75 up and to right) 
stimRect2 = round([Rect(3)/2+40, Rect(4)/2-(rectHeight(1)+40), Rect(3)/2+(rectWidth(1)+40), Rect(4)/2-40]);

%LOWER RIGHT, this displaces the box by half the size of the box (i.e., if box is 150x150, the top left corner will be 75x75 down and to right) 
stimRect3 = round([Rect(3)/2+40, Rect(4)/2+40, Rect(3)/2+(rectWidth(1)+40), Rect(4)/2+(rectHeight(1)+40)]);        %lower right of fixation

%LOWER LEFT, this displaces the box by half the size of the box (i.e., if box is 150x150, the top right corner will be 75x75 down and to left of fixation) 
stimRect4 = round([Rect(3)/2-(rectWidth(1)+40), Rect(4)/2+40, Rect(3)/2-40, Rect(4)/2+(rectHeight(1)+40)]);        %lower left of fixation

% flashing rect for blinks
blinkRect = round([Rect(3)/2-(rectWidth(1)+40), Rect(4)/2-(rectHeight(1)+40), Rect(3)/2+(rectWidth(1)+40), Rect(4)/2+(rectHeight(1)+40)]);

%% Load images

% Print a loading screen
DrawFormattedText(Window, 'Loading images -- the experiment will begin shortly','center','center', S.textColor);
Screen('Flip',Window);

% Read stimlist to load stims
[stsess, word, wordColor, distCond, dist, distPos, distCat, testLater] = MMT_fMRIReadStudyList(thePath,listName); 
cd(thePath.stim);

% Determine number of trials in block
nTrials = length(word);

% Now load the  images, make the textures, and store the texture pointers in an array
for n = 1:nTrials
    StSess          = stsess(n,:);
    Word            = word(n,:);                            % word
    WordColor       = wordColor(n,:);                       % word color
    DistCond        = distCond(n,:);                        % Whether memory will be tested for this item later
    Dist            = dist(n,:);                            % distractor picture
    DistPos         = distPos(n,:);                         % Location of target: L - left of fixation, R - right
    DistCat         = distCat(n,:);                         % Filename of stim (AK: is this right?)
    TestLater       = testLater(n,:);                       % Filename of stim (AK: is this right?)
 
    pic = imread(char(Dist),'jpg');
    picPtrs(n,1) = Screen('MakeTexture',Window,pic);    %pointer to stim
    picPtrs(n,2) = DistPos;                             %pointer to stim's position 
end

% fill theData struct with (redundant) data from stimlist to combine with
% response data
trialcount = 0;
theData.sNum = sNum;
theData.sSess = sSess;
theData.stsess = stsess(1:nTrials,:);
theData.word = word(1:nTrials,:);
theData.wordColor = wordColor(1:nTrials,:);
theData.distCond = distCond(1:nTrials,:);
theData.dist = dist(1:nTrials,:);
theData.distPos = distPos(1:nTrials,:);
theData.distCat = distCat(1:nTrials,:);
theData.testLater = testLater(1:nTrials,:);


% preallocate the actual data cells
for preall = 1:nTrials
        theData.onset(preall) = 0;
        theData.resp{preall} = 'noanswer';
        theData.respRT(preall) = 0;  
        theData.nullTime(preall) = 0;
end

%% set trial timing
leadinTime = 10.0;      % lead in time if scanning(to allow tissue equilibration at scanner)
stimTime = 0.3;         % stim duration
prestimTime = 1.0;
blinkTime = 2.0;
blinkRate = 0.5; % blink once every half-second
nBlinks = blinkTime/blinkRate;

ITIs = csvread('../jitter_poisson.csv'); % should be jittered btwn 2.8 and 3.2
ix = randperm(nTrials) + (nTrials * (sSess - 1));
ITIs = ITIs(ix);

%% start the scan

DrawFormattedText(Window, 'Get ready!\nExperimenter, press g to begin','center','center',S.textColor);
Screen('Flip',Window);

tic
goTime = 0;

%% start timing/trigger

    if scanner==3 % TRIGGER
        while 1
            getKey_old('g',S.kbNum);
            [status, startTime] = StartScan; % startTime corresponds to GetSecs in startScan
            fprintf('Status = %d\n',status);
            
            if status == 0  % successful trigger otherwise try again
                break
            else
                Screen(S.Window,'FillRect', S.screenColor);	% Blank Screen
                Screen(S.Window,'Flip');
                message = 'Trigger failed. \n Press g to try again.';
                DrawFormattedText(S.Window,message,'center','center',S.textColor);
                Screen(S.Window,'Flip');
            end
        end

        goTime = goTime + leadinTime;
        DrawFormattedText(Window,'+','center','center',S.textColor);
        Screen(S.Window,'Flip');
        recordKeys(startTime,goTime,d);  % not collecting keys, just a delay -- display 10 sec of "lead in" fixation before beginning

    elseif scanner == 4 % if hooked up to the EEG Netstation
        MU3getKey('g',S.kbNum);
        % start timing/trigger
        NetStation('Connect', '10.0.0.42'); %check this IP with the netstation
        WaitSecs(1);
        NetStation('Synchronize', 10);
        WaitSecs(1);
        NetStation('StartRecording');
        startTime = GetSecs; % for EEG, set this as the start time, all the onsets will be relative to this!
        goTime = goTime + leadinTime;
        DrawFormattedText(Window,'+','center','center',S.textColor);
        Screen(S.Window,'Flip');
        if (scanner == 4)
            NetStation('Synchronize', 10);
            NetStation('Event', 'CHK', GetSecs + 5);
        end
        recordKeys(startTime,goTime,d);
    
    else % practice, so don't wait for trigger
        if scanner == 1         % on laptop
            MU3getKey('g',d);
        elseif scanner == 2         % in scanner
            MU3getKey('g',S.kbNum);
        end
        
        startTime = GetSecs;
        goTime = goTime + 1;  %display 1 sec of "lead in" fixation before beginning
        DrawFormattedText(Window,'+','center','center',S.textColor);
        Screen(S.Window,'Flip');
        recordKeys(startTime,goTime,d);  % not collecting keys, just a delay -- display 4 sec of "lead in" fixation before beginning
        
    end

%% trial loop
for trial = startTrial:nTrials
    trialcount = trialcount + 1;
    theData.onset(trial) = GetSecs - startTime;
    ITI = ITIs(trial)/1000;

%% DISTRACTOR STIM
     goTime = goTime + stimTime;
     
     % place DISTRACTOR PIX in one of four quadrants
         if picPtrs(trial,2) == 1                                           % UPPER LEFT
                Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect1)  
         elseif picPtrs(trial,2) == 2                                       % UPPER RIGHT
                Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect2)  
         elseif picPtrs(trial,2) == 3                                       % LOWER RIGHT 
                Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect3)  
         elseif picPtrs(trial,2) == 4                                       % LOWER LEFT 
                Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect4)  
         end
        if scanner == 4
            % message must be <= 4 characters
            NetStation('Synchronize', 10);
            NetStation('Event', distCat(trial));
            % start time can be.. 
            % vbl returned by Screen('Flip')
            % goTime?
            % default: current time
        end
        
%% TARGET WORD
        task = 2; % 1: color task, 2: semantic task
        if task == 1
            % color task
            if wordColor(trial)==1 % red word
                DrawFormattedText(Window, word{trial},'center','center',[255 0 0]);        
            elseif wordColor(trial)==2 % blue word
                DrawFormattedText(Window, word{trial},'center','center',[0 0 255]);
            end
        elseif task == 2
            % semantic task
            DrawFormattedText(Window, word{trial},'center','center',255);
        end
        
        Screen('Flip',Window);                                          %show stims and annulus and fixation...
        [keys1 RT1] = recordKeys(startTime,goTime,d);

%% BLINK   
    
    if scanner == 4
            NetStation('Synchronize', 10);
            NetStation('Event', 'BLNK');       
    end
    if blinkType == 1
        for i = 1:nBlinks
            goTime = goTime + blinkTime/nBlinks - 0.1;
            
            Screen('FillRect',Window,[255,255,255],blinkRect)
            Screen('Flip',Window);
            recordKeys(startTime,goTime,d);
            
            goTime = goTime + 0.1;
            Screen('FillRect',Window,[0,0,0],blinkRect)
            Screen('Flip',Window);
            recordKeys(startTime,goTime,d);
        end
    elseif blinkType == 2
        goTime = goTime + blinkTime - 0.2;
        Screen('FillRect', Window, S.screenColor);  
        DrawFormattedText(Window, '[BLINK]', 'center', 'center', [0 206 209]);
        Screen('Flip', Window);
        recordKeys(startTime, goTime, d);
       
        goTime = goTime + 0.2;
        Screen('FillRect', Window, S.screenColor);  
        Screen('Flip', Window);

        recordKeys(startTime, goTime, d);
    end
    
    
%% FIXATION (incl prestim)
    goTime = goTime + ITI;
    DrawFormattedText(Window, '+','center','center',[255,255,255]);           %create white fixation screen
    Screen('Flip',Window); 
    
    if (scanner == 4)
        NetStation('Synchronize', 10);
        NetStation('Event', 'PRES', GetSecs + (ITI - prestimTime));
    end
    [keys2, RT2] = recordKeys(startTime,goTime,d);
                     
    
    %Put keypress and RT in theData struct...
    if (RT1 > 0) && (RT2 == 0)                                               %if responded during stim duration
        theData.resp{trial} = keys1(1);
        theData.respRT(trial) = RT1(1);
    elseif (RT2 > 0) && (RT1 == 0)                                           %if responded during post-stim fixation
        theData.resp{trial} = keys2(1);
        theData.respRT(trial) = stimTime+RT2(1);
    elseif (RT1 > 0) && (RT2 > 0)                                            %if responded during both periods
        theData.resp{trial} = [keys1(1) keys2(1)];
        theData.respRT(trial) = 0; % AK: no RT if responded twice??
    elseif (RT1 == 0) && (RT2 == 0)
        theData.resp{trial} = 'noresponse';
        theData.respRT(trial) = 0;
    else
        theData.resp{trial} = 'weirdness';
        theData.respRT(trial) = 0;
    end
        %output resp info to the command line...
        disp(['trial: ' num2str(trial)]);
        disp(['response: ' theData.resp{trial}]);
        disp(['RT: ' num2str(theData.respRT(trial))]);
        disp(['ITI: ' num2str(ITI)]);
             
end
toc

%% calculate summary stats, save data, clean up
RTnoDist = median(theData.respRT(strcmp('ND', theData.distCond)));
RTDist = median(theData.respRT(strcmp('D', theData.distCond)));
Noresp = sum(strcmp('noresponse',theData.resp));


fprintf(['\nExpected time: ' num2str(goTime)]);
fprintf(['\nActual time: ' num2str(GetSecs-startTime)]);

fprintf(['\nMedian no-distractor RT for this session: ' num2str(RTnoDist)]);
fprintf(['\nMedian distractor RT for this session: ' num2str(RTDist)]);
fprintf(['\nNumber of omitted responses: ' num2str(Noresp)]);

% save output file
cd(thePath.logfiles);

%make Subj-specific directory for logfiles
SubjDir = ['s' num2str(sNum)]
if ~exist(SubjDir,'dir'); mkdir(SubjDir); end
cd(SubjDir);


matName = [listName 'out.mat'];
save(matName);

% make savename unique for non-1 start trials
if startTrial > 1
saveName = [listName '_' sName '_out_' startTrial '.txt'];
else
saveName = [listName '_' sName '_out.txt'];
end

fid = fopen(saveName, 'wt');
fprintf(fid, ('subjNum\tsessInput\tstudySess\tonset\tword\twordColor\tdistCond\tdist\tdistPos\tdistCat\ttestLater\tresp\tRT\tITI\n'));
for n = 1:trialcount
    fprintf(fid, '%f\t%f\t%f\t%f\t%s\t%f\t%s\t%s\t%f\t%s\t%s\t%s\t%f\n',...
        theData.sNum,theData.sSess,theData.stsess(n),theData.onset(n),theData.word{n},theData.wordColor(n),...
        theData.distCond{n}, theData.dist{n},theData.distPos(n), theData.distCat{n}, theData.testLater{n}, ...
        theData.resp{n}, theData.respRT(n), ITIs(n));
        
end

Screen('FillRect',Window,0);                                        
Screen('Flip',Window);                                              
pause(2);                                                           
% Print a goodbye screen
DrawFormattedText(Window, 'End of this session!','center','center',255); 
Screen('Flip',Window);

pause(2);                                                              % wait for any keypress to close the screen
clear screen
ShowCursor;

if scanner == 4 % if EEG
    NetStation('StopRecording');
end
    
cd(thePath.start);                                                  %return to main directory




