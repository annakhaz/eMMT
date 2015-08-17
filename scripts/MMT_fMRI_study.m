function theData = MMT_fMRI_study(thePath,listName,startTrial)

% Run the Endo/Exo attention and subs memory expt. (MU3)
% Example use:
%  theData = MMT_fMRI_study(thePath,'fMMT001_study1',1)
% written by Melina Uncapher 4/21/08, 
%PsychDebugWindowConfiguration

%workaround for using retina
Screen('Preference', 'SkipSyncTests', 1);

while 1
    scanner = input('Practice on laptop [1], Practice in scanner [2], or REAL EXPT in scanner [3]? ');
    % Set input device (keyboard or buttonbox)
    if scanner == 2 || scanner == 3
        d = getBoxNumber;  % buttonbox
%         d = getBoxNumber_testing;  % buttonbox TESTING - PUT BACK PREVIOUS LINE PRIOR TO SCANNING!!!
        S.kbNum = getKeyboardNumber_Anna;
%         thePath.stim = [thePath.stim '_small']; % use smaller stim if in the scanner
        break
    elseif scanner == 1
        d = getKeyboardNumber_Anna; % gets device number of the keyboard using PsychHID('Devices')
        break
    end
end

%Input subject info:
sName = input('Enter subject initials: ','s');
sNum = input('Enter subject number: ');
sSess = input('Enter session number: ');
sSemCol = input('Enter task type, sem[1] or col[2]: ');

%Initialize screen:
if scanner == 2 || scanner == 3
    [Window,Rect] = MU3initializeScreen; %display on secondary monitor
elseif scanner == 1
    [Window,Rect] = MU3initializeScreen_laptop; %display on primary monitor
end    

%------------------------------------------
% partially redundant with MU3initializeScreen, but useful for now...
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
    end
%------------------------------------------
 
% creates rects of specified pixel size in which to place stim 
rectHeight(1) = 150;
rectWidth(1) = 150;


%UPPER LEFT, this displaces the box by half the size of the box (i.e., if box is 150x150, the bottom right corner will be 75x75 up and to left of fixation) 
% stimRect1 = round([Rect(3)/2-rectWidth(1)*2, Rect(4)/2-rectHeight(1)*2,Rect(3)/2-rectWidth(1), Rect(4)/2-rectHeight(1)]); 
stimRect1 = round([Rect(3)/2-(rectWidth(1)+40), Rect(4)/2-(rectHeight(1)+40),Rect(3)/2-40, Rect(4)/2-40]); 

%UPPER RIGHT, this displaces the box by half the size of the box (i.e., if box is 150x150, the bottom left corner will be 75x75 up and to right) 
% stimRect2 = round([Rect(3)/2+rectWidth(1), Rect(4)/2-rectHeight(1)*2, Rect(3)/2+rectWidth(1)*2, Rect(4)/2-rectHeight(1)]);
stimRect2 = round([Rect(3)/2+40, Rect(4)/2-(rectHeight(1)+40), Rect(3)/2+(rectWidth(1)+40), Rect(4)/2-40]);

%LOWER RIGHT, this displaces the box by half the size of the box (i.e., if box is 150x150, the top left corner will be 75x75 down and to right) 
% stimRect3 = round([Rect(3)/2+rectWidth(1), Rect(4)/2+rectHeight(1), Rect(3)/2+rectWidth(1)*2, Rect(4)/2+rectHeight(1)*2]);        %lower right of fixation
stimRect3 = round([Rect(3)/2+40, Rect(4)/2+40, Rect(3)/2+(rectWidth(1)+40), Rect(4)/2+(rectHeight(1)+40)]);        %lower right of fixation

%LOWER LEFT, this displaces the box by half the size of the box (i.e., if box is 150x150, the top right corner will be 75x75 down and to left of fixation) 
% stimRect4 = round([Rect(3)/2-rectWidth(1)*2, Rect(4)/2+rectHeight(1), Rect(3)/2-rectWidth(1), Rect(4)/2+rectHeight(1)*2]);        %lower left of fixation
stimRect4 = round([Rect(3)/2-(rectWidth(1)+40), Rect(4)/2+40, Rect(3)/2-40, Rect(4)/2+(rectHeight(1)+40)]);        %lower left of fixation

%------------------------------------------


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
    WordColor       = wordColor(n,:);                            % word color
    DistCond        = distCond(n,:);                          % Whether memory will be tested for this item later
    Dist            = dist(n,:);                    % distractor picture
    DistPos         = distPos(n,:);                          % Location of target: L - left of fixation, R - right
    DistCat         = distCat(n,:);                             % Filename of stim
    TestLater       = testLater(n,:);                             % Filename of stim

%     if strcmp(objCond(n),'NULL')                           % for non-null trials, load images...
%     else 
    pic = imread(char(Dist),'jpg');
    picPtrs(n,1) = Screen('MakeTexture',Window,pic);   %pointer to stim
    picPtrs(n,2) = DistPos;                             %pointer to stim's position 
%     end
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


%THESE VARIABLES HAVE CONSTANT TIMING ACROSS TRIALS...
leadinTime = 12.0;      % lead in time if scanning(to allow tissue equilibration at scanner)
stimTime = 0.3;         % stim duration
ITI = 7.7;

% ITI = 3.7; %FOR BEHAVIORAL PILOTING, ITI WAS 3.7 FOR A TOTAL TRIAL TIME OF 4.0s

% stimTime = .01;         % stim duration
% ITI = .01;
% 
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
   
% %DETERMINE WHETHER TRIAL IS NULL EVENT OR EXPT'L TRIAL... 
% 
% %NULL TRIAL...
% if strcmp(objCond(trial),'NULL')
%     DrawFormattedText(Window, '+','center','center',[255,255,255]);         %create white fixation 
%     Screen('Flip',Window);                                                  %draw white fixation
%     recordKeys(GetSecs,theData.nullTime(trial),d);                          %not actually recording keypress
%     theData.resp{preall} = 'null';
%     theData.respRT(preall) = 0;
% 
% %EXPERIMENTAL TRIAL... 
% else                                                                                       
%     
    
% STIM ...
     goTime = goTime + stimTime;
     
     %this guy places DISTRACTOR PIX in one of four quadrants, as specified by picPtrs(trial,2)...
         if picPtrs(trial,2) == 1                                           %indicates UPPER LEFT
                Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect1)  %draw stim 
         elseif picPtrs(trial,2) == 2                                       %indicates UPPER RIGHT
                Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect2)  %draw stim 
         elseif picPtrs(trial,2) == 3                                       %indicates LOWER RIGHT 
                Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect3)  %draw stim 
         elseif picPtrs(trial,2) == 4                                       %indicates LOWER LEFT 
                Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect4)  %draw stim 
         end
    
         
         
    %NOW DRAW THE TARGET WORD...
    if sSemCol == 2   % color task 
       if wordColor(trial)==1 % red word
             DrawFormattedText(Window, word{trial},'center','center',[255 0 0]);           %red
        elseif wordColor(trial)==2 % blue word
            DrawFormattedText(Window, word{trial},'center','center',[0 0 255]);   %blue
       end
    else 
         DrawFormattedText(Window, word{trial},'center','center',255);           %white
    end
        Screen('Flip',Window);                                          %show stims and annulus and fixation...
        [keys1 RT1] = recordKeys(startTime,goTime,d);

% FIXATION...
    goTime = goTime + ITI;
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
        

% end % end of Null vs. Exptl trials loop  
      
end % end of TRIALS LOOP
%--------------------------------------------
toc

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
fprintf(fid, ('subjNum\tsessInput\tstudySess\tonset\tword\twordColor\tdistCond\tdist\tdistPos\tdistCat\ttestLater\tresp\tRT\n'));
for n = 1:trialcount
    fprintf(fid, '%f\t%f\t%f\t%f\t%s\t%f\t%s\t%s\t%f\t%s\t%s\t%s\t%f\n',...
        theData.sNum,theData.sSess,theData.stsess(n),theData.onset(n),theData.word{n},theData.wordColor(n),...
        theData.distCond{n}, theData.dist{n},theData.distPos(n), theData.distCat{n}, theData.testLater{n}, ...
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




