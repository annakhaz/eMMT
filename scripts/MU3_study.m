function theData = MU3_study(thePath,listName,startTrial)

% Run the Endo/Exo attention and subs memory expt. (MU3)
% Example use:
%  theData = MU3_study(thePath,'MU3001_study1',1);
% written by Melina Uncapher 4/21/08, 

while 1
    scanner = input('Practice on laptop [1], Practice in scanner [2], or REAL EXPT in scanner [3]? ');
    % Set input device (keyboard or buttonbox)
    if scanner == 2 || scanner == 3
        d = getBoxNumber;  % buttonbox
%         d = getBoxNumber_testing;  % buttonbox TESTING - PUT BACK PREVIOUS LINE PRIOR TO SCANNING!!!
        S.kbNum = getKeyboardNumber_Recca;
%         thePath.stim = [thePath.stim '_small']; % use smaller stim if in the scanner
        break
    elseif scanner == 1
        d = MU3getKeyboardNumber; % gets device number of the keyboard using PsychHID('Devices')
        break
    end
end

%Input subject info:
sName = input('Enter subject initials: ','s');
sNum = input('Enter subject number: ');
sSess = input('Enter session number: ');

%Initialize screen:
if scanner == 2 || scanner == 3
    [Window,Rect] = MU3initializeScreen; %display on secondary monitor
elseif scanner == 1
    [Window,Rect] = MU3initializeScreen_laptop; %display on primary monitor
end    

%------------------------------------------
% redundant with MU3initializeScreen, but useful for now...
S.on = 0;  % Screen hasn't been opened yet

% Screen commands
    if S.on == 0  % Screen hasn't been opened yet
        if scanner == 2 || scanner == 3
            S.screenNumber = 1; % 0: primary monitor, 1: second monitor
        elseif scanner == 1
            S.screenNumber = 0;
        end
        S.screenColor = 0; %black screen
        S.textColor = 255;  %white text
        [S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow', S.screenColor, []);
        Screen(S.Window,'TextSize', 40);
    end
%------------------------------------------
 
% create 2 rects of size 200x200 pixels in which to place stim 
rectHeight(1) = 150;
rectWidth(1) = 150;

stimRect1 = round([Rect(1)+Rect(3)/2-rectWidth(1)/2+130, Rect(2)+Rect(4)/2-rectHeight(1)/2, Rect(3)/2+rectWidth(1)/2+130, Rect(4)/2+rectHeight(1)/2]);        %right of fixation
stimRect2 = round([Rect(1)+Rect(3)/2-rectWidth(1)/2-130, Rect(2)+Rect(4)/2-rectHeight(1)/2, Rect(3)/2+rectWidth(1)/2-130, Rect(4)/2+rectHeight(1)/2]);        %left of fixation

%create rect for Left/Right arrow cue
rectHeight(2) = 100;
rectWidth(2) =  100;

stimRect3 = round([Rect(1)+Rect(3)/2-rectWidth(2)/2, Rect(2)+Rect(4)/2-rectHeight(2)/2, Rect(3)/2+rectWidth(2)/2, Rect(4)/2+rectHeight(2)/2]);

% Print a loading screen
DrawFormattedText(Window, 'Loading images -- the experiment will begin shortly','center','center',S.textColor);
Screen('Flip',Window);

% Read stimlist to load stims
[stsess, objCond, validityCond, LRcue, stimpos, stim, jitter, memCond] = MU3ReadStudyList(thePath,listName); 
cd(thePath.stim);

% Determine number of trials in block
nTrials = length(objCond);

% Now load the  images, make the textures, and store the texture pointers in an array
for n = 1:nTrials
    StSess          = stsess(n,:);
    ObjCond         = objCond(n,:);                          % Type of trial: OBJ - meaningful line drawing, NON - meaningless line drawing, NULL - null event
    ValCond         = validityCond(n,:);                     % Whether cue is valid or invalid: V - valid, NV - invalid
    LRCue           = LRcue(n,:);                            % Direction of arrow, cueing location of attention: L - left of fixation, R - right
    picpos          = stimpos(n,:);                          % Location of target: L - left of fixation, R - right
    picname         = stim(n,:);                             % Filename of stim
    timing          = jitter(n,:);                           % Jittered timing structure of each trial
    MemCond         = memCond(n,:);                          % Whether memory will be tested for this item later
    
    if strcmp(objCond(n),'NULL')                           % for non-null trials, load images...
    else 
    pic = imread(char(picname),'jpg');
    picPtrs(n,1) = Screen('MakeTexture',Window,pic);   %pointer to stim
    picPtrs(n,2) = picpos;                             %pointer to stim's position 
    end
end

% fill theData struct with (redundant) data from stimlist to combine with
% response data
trialcount = 0;
theData.sNum = sNum;
theData.sSess = sSess;
theData.stsess = stsess(1:nTrials,:);
theData.objCond = objCond(1:nTrials,:);
theData.validityCond = validityCond(1:nTrials,:);
theData.LRcue = LRcue(1:nTrials,:);
theData.stimpos = stimpos(1:nTrials,:);
theData.stim = stim(1:nTrials,:);
theData.timing = jitter(1:nTrials,:);
theData.memCond = memCond(1:nTrials,:);

% preallocate the actual data cells
for preall = 1:nTrials
        theData.onset(preall) = 0;
        theData.resp{preall} = 'noanswer';
        theData.respRT(preall) = 0;  
        
        theData.cuedelayTime(preall) = 0;
        theData.arraydelayTime(preall) = 0;
        theData.nullTime(preall) = 0;
end

% JITTERED DESIGN:
% Diagram of trial (in secs):  cue (2s), cuedelay (2, 4 or 6s), stim (1s), stimdelay (1 or 3s)
% null events randomly interspersed of length 2 or 4s (but after stimdelay, so effectively 2, 4, or 6sec)
 %ASSIGN VALUES TO THESE VARIABLES (WHICH HAVE VARIABLE TIMING ACROSS TRIALS)...
for nn = 1:nTrials
   % variable CUE delay (delay between cue and stim):
    if jitter(nn) == 1 || jitter(nn) ==4 || jitter(nn) == 7
        theData.cuedelayTime(nn) = 1.0;          
    elseif jitter(nn) == 2 || jitter(nn) == 5 || jitter(nn) == 8
        theData.cuedelayTime(nn) = 3.0;         
    elseif jitter(nn) == 3 || jitter(nn) == 6 || jitter(nn) == 9
        theData.cuedelayTime(nn) = 5.0;          
    end
    
    % variable ARRAY delay (delay between stim and end of trial):
    if jitter(nn) == 1 || jitter(nn) == 2 || jitter(nn) == 3
        theData.arraydelayTime(nn) = 1.5;        
    elseif jitter(nn) == 4 || jitter(nn) == 5 || jitter(nn) == 6
        theData.arraydelayTime(nn) = 3.5;         
    elseif jitter(nn) == 7 || jitter(nn) == 8 || jitter(nn) == 9
        theData.arraydelayTime(nn) = 5.5;         
    end

    % variable ITI (delay between probe and next trial):
    if jitter(nn) == 10 
        theData.nullTime(nn) = 4.0;              
    elseif jitter(nn) == 11 
        theData.nullTime(nn) = 6.0;  
    end
end

%THESE VARIABLES HAVE CONSTANT TIMING ACROSS TRIALS...
cueTime = 1.0;          % cue duration 
stimTime = 0.5;         % stim duration
leadinTime = 12.0;      % lead in time (to allow tissue equilibration at scanner

% Print a ready screen and wait for a keypress (G) to start the phase
DrawFormattedText(Window, 'Get ready!\nExperimenter, press G to begin','center','center',S.textColor);
Screen('Flip',Window);

tic
% Wait for keypress 'g'
goTime = 0;

%------------------------------------------------
% MODIFICATIONS TO ALLOW FOR SCANNER TRIGGER...   
% Start the experiment
    % start timing/trigger

    if scanner==3
        % *** TRIGGER ***
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
        Screen('FrameRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
        Screen('FillRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
        Screen('FrameRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
        Screen('FillRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
        DrawFormattedText(Window,'+','center','center',S.textColor);
        Screen(S.Window,'Flip');
        recordKeys(startTime,goTime,d);  % not collecting keys, just a delay -- display 10 sec of "lead in" fixation before beginning


    else
            if scanner == 1         %practice on laptop so don't wait for trigger
            MU3getKey('g',d);
            elseif scanner == 2         %practice in scanner so don't wait for trigger
            MU3getKey('g',S.kbNum);
            end
        startTime = GetSecs;
        goTime = goTime + 4;  %display 4 sec of "lead in" fixation before beginning 
        Screen('FrameRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
        Screen('FillRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
        Screen('FrameRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
        Screen('FillRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
        DrawFormattedText(Window,'+','center','center',S.textColor);
        Screen(S.Window,'Flip');
        recordKeys(startTime,goTime,d);  % not collecting keys, just a delay -- display 4 sec of "lead in" fixation before beginning
        
    end
%------------------------------

% % Lead-in
% goTime = startTime + leadinTime;
% Screen('FillRect', Window, 0);
% Screen('Flip', Window);

%--------------------------------------------
% TRIAL LOOP
for trial = startTrial:nTrials
    trialcount = trialcount + 1;
    theData.onset(trial) = GetSecs - startTime;
   
%DETERMINE WHETHER TRIAL IS NULL EVENT OR EXPT'L TRIAL... 

%NULL TRIAL...
if strcmp(objCond(trial),'NULL')
    Screen('FrameRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
    Screen('FillRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
    Screen('FrameRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
    Screen('FillRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
    DrawFormattedText(Window, '+','center','center',[255,255,255]);         %create white fixation 
    Screen('Flip',Window);                                                  %draw white fixation
    recordKeys(GetSecs,theData.nullTime(trial),d);                          %not actually recording keypress
    theData.resp{preall} = 'null';
    theData.respRT(preall) = 0;

%EXPERIMENTAL TRIAL... 
else                                                                                       
                                                           
% LEFT/RIGHT ARROW CUE...
  goTime = goTime + cueTime;
  % Drawing cues online...
    if strcmp(LRcue(trial),'L')                                                                  %cue indicates to subject to 'Attend to Left box' in upcoming array
        % Draw LEFT ARROW
        Screen('FramePoly', Window, [0,255,0],[(stimRect3(1)+stimRect3(3))/2,stimRect3(2);...
            (stimRect3(1)+stimRect3(3))/2,stimRect3(4);stimRect3(1),(stimRect3(2)+stimRect3(4))/2]);  %draw left-pointing arrow to cue 'Attend Left'
        Screen('FillPoly',Window,[0,255,0],[(stimRect3(1)+stimRect3(3))/2,stimRect3(2);...
            (stimRect3(1)+stimRect3(3))/2,stimRect3(4);stimRect3(1),(stimRect3(2)+stimRect3(4))/2]);     %fill triangle
    elseif strcmp(LRcue(trial),'R')                                                              %cue indicates to subject to 'Attend to red items only' in upcoming array
        % Draw RIGHT ARROW
        Screen('FramePoly', Window, [0,255,0],[(stimRect3(1)+stimRect3(3))/2,stimRect3(2);...
            (stimRect3(1)+stimRect3(3))/2,stimRect3(4);stimRect3(3),(stimRect3(2)+stimRect3(4))/2]);  %draw left-pointing arrow to cue 'Attend Left'
        Screen('FillPoly',Window,[0,255,0],[(stimRect3(1)+stimRect3(3))/2,stimRect3(2);...
            (stimRect3(1)+stimRect3(3))/2,stimRect3(4);stimRect3(3),(stimRect3(2)+stimRect3(4))/2]);     %fill triangle
    end
    Screen('FrameRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
    Screen('FillRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
    Screen('FrameRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
    Screen('FillRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
    Screen('Flip',Window);                                          %draw cue
    recordKeys(startTime,goTime,d);
    
% BACK TO FIXATION (and white boxes) FOR VARIABLE DELAY...
    goTime = goTime + theData.cuedelayTime(trial);
    Screen('FrameRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
    Screen('FillRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
    Screen('FrameRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
    Screen('FillRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
    DrawFormattedText(Window, '+','center','center',255);                       %WHITE fixation 
    Screen('Flip',Window);                                                      %draw fixation
    recordKeys(startTime,goTime,d);
    
% STIM ...
     goTime = goTime + stimTime;
     %this guy places indicated stim in left or right position...
     if picPtrs(trial,2) == 1                                           %indicates RIGHT of fixation
            Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect1)  %draw stim RIGHT of fixation
            Screen('FrameRect', Window, [255,255,255],stimRect2);       % white box to left of fixation
            Screen('FillRect', Window, [255,255,255],stimRect2);        % white box to left of fixation
     elseif picPtrs(trial,2) == 2                                       %indicates LEFT of fixation
            Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect2)  %draw stim LEFT of fixation
            Screen('FrameRect', Window, [255,255,255],stimRect1);        % white box to right of fixation
            Screen('FillRect', Window, [255,255,255],stimRect1);         % white box to right of fixation
    end
    DrawFormattedText(Window, '+','center','center',[255,255,255]);           %create white fixation screen
    Screen('Flip',Window);                                          %show stims and annulus and fixation...
    [keys1 RT1] = recordKeys(startTime,goTime,d);

% FIXATION...
    goTime = goTime + theData.arraydelayTime(trial);
    Screen('FrameRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
    Screen('FillRect', Window, [255,255,255],stimRect1);                         % white box to right of fixation
    Screen('FrameRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
    Screen('FillRect', Window, [255,255,255],stimRect2);                         % white box to left of fixation
    DrawFormattedText(Window, '+','center','center',[255,255,255]);           %create white fixation screen
    Screen('Flip',Window);                                                  %draw white fixation
    [keys2 RT2] = recordKeys(startTime,goTime,d);                       %if respond after probe (more likely), record keypress
    
    %Put keypress and RT in theData struct...
    if (RT1 > 0) & (RT2 == 0)                                               %if responded during stim duration
        theData.resp{trial} = keys1(1);
        theData.respRT(trial) = RT1(1);
    elseif (RT2 > 0) & (RT1 == 0)                                           %if responded during post-stim fixation
        theData.resp{trial} = keys2(1);
        theData.respRT(trial) = stimTime+RT2(1);
    elseif (RT1 > 0) & (RT2 > 0)                                            %if responded during both periods
        theData.resp{trial} = [keys1(1) keys2(1)];
        theData.respRT(trial) = 0;
    elseif (RT1 == 0) & (RT2 == 0)
        theData.resp{trial} = 'noresponse';
        theData.respRT(trial) = 0;
    else
        theData.resp{trial} = 'weirdness';
        theData.respRT(trial) = 0;
    end

        %output resp info to the command line...
        trial
        theData.resp{trial}
        theData.respRT(trial)
        

end % end of Null vs. Exptl trials loop  
      
end % end of TRIALS LOOP
%--------------------------------------------
toc

RTvalid = median(theData.respRT(strcmp('V', theData.validityCond)));
RTinvalid = median(theData.respRT(strcmp('NV', theData.validityCond)));
Noresp = sum(strcmp('noresponse',theData.resp));

fprintf(['\nExpected time: ' num2str(goTime)]);
fprintf(['\nActual time: ' num2str(GetSecs-startTime)]);

fprintf(['\nMedian valid RT for this session: ' num2str(RTvalid)]);
fprintf(['\nMedian invalid RT for this session: ' num2str(RTinvalid)]);
fprintf(['\nNumber of omitted responses: ' num2str(Noresp)]);

% save output file
cd(thePath.logfiles);

% matName = [listName(1:end-3) 'out.mat'];
matName = [listName 'out.mat'];
cmd = ['save ' matName];
eval(cmd);

% make savename unique for non-1 start trials
if startTrial > 1
% saveName = [listName(1:end-4) '.' sName '.out_' startTrial '.txt'];
saveName = [listName '.' sName '.out_' startTrial '.txt'];
else
% saveName = [listName(1:end-4) '.' sName '.out.txt'];
saveName = [listName '.' sName '.out.txt'];
end

fid = fopen(saveName, 'wt');        %'wt' indicates write text mode; used for compatibility across text reading programs
fprintf(fid, ('subjNum\tsessInput\tstudySess\tonset\tobjCond\tvalidityCond\tLRcue\tstimpos\tstim\tjitter\tmemCond\tcuedelayTime\tarraydelayTime\tnullTime\tresp\tRT\n'));
for n = 1:trialcount
    fprintf(fid, '%f\t%f\t%f\t%f\t%s\t%s\t%s\t%f\t%s\t%f\t%s\t%f\t%f\t%f\t%s\t%f\n',...
        theData.sNum,theData.sSess,theData.stsess(n),theData.onset(n),theData.objCond{n},theData.validityCond{n}, theData.LRcue{n}, theData.stimpos(n),...
        theData.stim{n}, theData.timing(n), theData.memCond{n}, theData.cuedelayTime(n),theData.arraydelayTime(n),theData.nullTime(n),...
        theData.resp{n}, theData.respRT(n));
        
end


Screen('FillRect',Window,0);                                        %create blank screen to indicate end of block, 0=black
Screen('Flip',Window);                                              %draw blank screen
pause(2);                                                           %wait 2 seconds before displaying 'end of script' message
% Print a goodbye screen
DrawFormattedText(Window, 'End of this session!\nExperimenter, press any key to exit','center','center',255); 
Screen('Flip',Window);

pause;                                                              % wait for any keypress to close the screen
clear screen
ShowCursor;

cd(thePath.start);                                                  %return to main directory




