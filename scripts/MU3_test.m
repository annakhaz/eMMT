function theData = MU3_test(thePath,listName,startTrial)

% Run the Endo/exo subsequent memory expt. 
% Example use:
%  theData = MU3_study(thePath,'MU.practice.1.1');
% written by Melina Uncapher 4/21/08, 

%Input subject info:
sName = input('Enter subject initials: ','s');
sNum = input('Enter subject number: ');
sSess = input('Enter session number: ');
sScreenType = input('Testing on laptop [1] or with 2 monitors [2]? ');
% sCond = input('Test stim in gray [1] or color [2]? ');
sCond = 1 ;
sSource = 1;

% Diagram of trial (in secs)
cueTime = .5;           % red fixation duration (indicates an upcoming event)
% stimTime = 1.5;          % stimulus duration
fixTime = 1.5;          % white fixation duration

%Initialize screen:
if sScreenType == 1
    [Window,Rect] = MU3initializeScreen_laptop;
else
    [Window,Rect] = MU3initializeScreen;
end
 
% create 1 rect of size 110x110 pixels in which to place test stim 
rectHeight(1) = 200; 
rectWidth(1) = 200;

stimRect1 = round([Rect(1)+Rect(3)/2-rectWidth(1)/2, Rect(2)+Rect(4)/2-rectHeight(1)/2, Rect(3)/2+rectWidth(1)/2, Rect(4)/2+rectHeight(1)/2]);

% create 2 rects of size 500x500 pixels in which to place location and color (study source) mapping  
rectHeight(2) = 500; 
rectWidth(2) = 500;
stimRect2 = round([Rect(1)+Rect(3)/2-rectWidth(2)/2, Rect(2)+Rect(4)/2-rectHeight(2)/2, Rect(3)/2+rectWidth(2)/2, Rect(4)/2+rectHeight(2)/2]);
stimRect3 = round([Rect(1)+Rect(3)/2-rectWidth(2)/2, Rect(2)+Rect(4)/2-rectHeight(2)/2, Rect(3)/2+rectWidth(2)/2, Rect(4)/2+rectHeight(2)/2]);


% Print a loading screen
DrawFormattedText(Window, 'Loading images -- the experiment will begin shortly','center','center',255);
Screen('Flip',Window);

% Read stimlist to load stims
[teststim, studystim, studysess, studytrial, studypos, studycolor, validityCond, studyjitter] = MU3ReadTestList(thePath,listName); 
cd(thePath.stim);

% Determine number of trials in block
nTrials = length(teststim);
% LOCmapping_img = imread('SourceLoc.jpg');
% COLmapping_img = imread('SourceCol.jpg');

% Now load the  images, make the textures, and store the texture pointers in an array
for n = 1:nTrials
    if sCond == 1
        picname_teststim = teststim(n,:);                              % TEST ITEMS IN GRAY (PILOTING)
    elseif sCond == 2
        picname_teststim = studystim(n,:);                             % TEST ITEMS IN COLOR (PILOTING)
    end
    pic1 = imread(char(picname_teststim),'jpg');
    picPtrs(n,1) = Screen('MakeTexture',Window,pic1);               %pointer to teststim
    
%     LOCmappingPtr = Screen('MakeTexture',Window,LOCmapping_img);        %pointer to response mapping image (annulus with 8 positions)  
%     COLmappingPtr = Screen('MakeTexture',Window,COLmapping_img);        %pointer to response mapping image (annulus with 8 positions)  
    
end

% fill theData struct with (redundant) data from stimlist 
trialcount = 0;
theData.sNum = sNum;
theData.stimColor = sCond;
theData.testType = sSource;
theData.testitem = teststim(1:nTrials,:);
theData.studyitem = studystim(1:nTrials,:);
theData.studysess = studysess(1:nTrials,:);
theData.studytrial = studytrial(1:nTrials,:);
theData.studypos = studypos(1:nTrials,:);
theData.studycolor = studycolor(1:nTrials,:);
theData.validityCond = validityCond(1:nTrials,:);
theData.studytiming = studyjitter(1:nTrials,:);

% preallocate the actual data cells
for preall = 1:nTrials
        theData.onset(preall) = 0;
        theData.recogresp{preall} = 'noanswer';
        theData.recogrespRT(preall) = 0;
        theData.Loc_resp{preall} = 'noanswer';
        theData.Loc_respRT(preall) = 0;
        theData.Col_resp{preall} = 'noanswer';
        theData.Col_respRT(preall) = 0;
end

% Print a ready screen and wait for a keypress (G) to start the phase
DrawFormattedText(Window, 'Press G to begin','center','center',255);
Screen('Flip',Window);
    
% Wait for keypress 'g' to begin
d = MU3getKeyboardNumber; % gets device number of the keyboard using PsychHID('Devices')
MU3getKey('g',d);
startTime = GetSecs;        %begins timing

% Start the experiment
goTime = 0;
leadinTime = 2;
% stimDur = 5;

% Lead-in
goTime = goTime + leadinTime;
Screen('FillRect', Window, 0);
Screen('Flip', Window);

%--------------------------------------------
% TRIAL LOOP
for trial = startTrial:nTrials
    trialcount = trialcount + 1;
    theData.onset(trial) = GetSecs - startTime;
                                                         
% RED (CUE) FIXATION...
    DrawFormattedText(Window, '+','center','center',[0,255,0]);     %create green fixation
    Screen('Flip',Window);                                          %draw red or white fixation
    recordKeys(GetSecs,cueTime,d);
    
% TEST STIM ...
    Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect1)      %draw stim in 1st position (left of fixation)
    Screen('Flip',Window);                                          %show stims and white fixation...
  
        [recogkeys recogRT] = recordKeys(GetSecs,4,d,1);            %allow up to 4sec to make old/new response
        theData.recogresp{trial} = recogkeys(1);
        theData.recogrespRT(trial) = recogRT(1);
        trial
        theData.recogresp{trial}
        theData.recogrespRT(trial)
        
  if sSource == 1   %testing memory for location and color      
   %if responded 'old', display response map annulus for location judgment, then color question for color judgment...     
    if theData.recogresp{trial} == 'f' || theData.recogresp{trial} == 'd'                             
        %first location:
%         Screen('DrawTexture',Window,LOCmappingPtr,[],stimRect2);       %create response mapping screen
        Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect1)      %draw stim in 1st position (left of fixation)
        DrawFormattedText(Window, 'LEFT? [f]',stimRect1(1)-170,'center',[255,255,255]);     %create red question
        DrawFormattedText(Window, 'RIGHT? [j]',stimRect1(3)+20,'center',[255,255,255]);     %create blue question
        Screen('Flip',Window);                                      %draw screen
        [Loc_keys Loc_RT] = recordKeys(GetSecs,5,d,1)               %allow up to 5sec to make source location response
        theData.Loc_resp{trial} = Loc_keys(1);                      %record source location response
        theData.Loc_respRT(trial) = Loc_RT(1);
        
%         %then color:
%         Screen('DrawTexture',Window,picPtrs(trial,1),[],stimRect1)      %draw stim in 1st position (left of fixation)
%         DrawFormattedText(Window, 'RED? [d]',stimRect1(1)-150,'center',[255,0,0]);     %create red question
%         DrawFormattedText(Window, 'BLUE? [f]',stimRect1(3)+10,'center',[0,0,255]);     %create blue question
%         Screen('Flip',Window); 
%         [Col_keys Col_RT] = recordKeys(GetSecs,5,d,1)           %allow up to 5sec to make source location response
%         theData.Col_resp{trial} = Col_keys(1);                  %record source location response
%         theData.Col_respRT(trial) = Col_RT(1);

    else  %no response or responded new or with incorrect key
        DrawFormattedText(Window, '+','center','center',255);       %create white fixation screen
        Screen('Flip',Window);                                      %draw white fixation
    end
  elseif sSource == 2   % NOT testing memory for location and color      
        DrawFormattedText(Window, '+','center','center',255);       %create white fixation screen
        Screen('Flip',Window);                                      %draw white fixation
  end
    
% FIXATION 
    DrawFormattedText(Window, '+','center','center',255);           %create white fixation screen
    Screen('Flip',Window);                                          %draw white fixation
    recordKeys(GetSecs,fixTime,d);                                  %not actually recording keypress

end % end of TRIALS LOOP
%--------------------------------------------

% fprintf(['\nExpected time: ' num2str(goTime)]);
% fprintf(['\nActual time: ' num2str(GetSecs-startTime)]);

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

if sSource == 1     % create logfiles for source judgments
    fid = fopen(saveName, 'wt');        %'wt' indicates write text mode; used for compatibility across text reading programs
    fprintf(fid, ('subjNum\tstimColor\ttestType\tstudyonset\ttestitem\tstudyitem\tstudysession\tstudytrial\tstudypos\tstudycolor\tvalidityCond\tstudyjitter\trecogresp\trecogRT\tLoc_resp\tLocRT\n'));
    for n = 1:trialcount    % '%f' for fixed point notation (nums), '%s' for characters
        fprintf(fid, '%f\t%f\t%f\t%f\t%s\t%s\t%f\t%f\t%f\t%s\t%s\t%f\t%s\t%f\t%s\t%f\n',...
        theData.sNum, theData.stimColor, theData.testType, theData.onset(n), theData.testitem{n}, theData.studyitem{n}, theData.studysess(n), theData.studytrial(n), ...
        theData.studypos(n), theData.studycolor{n}, theData.validityCond{n}, theData.studytiming(n), theData.recogresp{n}, theData.recogrespRT(n),...
        theData.Loc_resp{n}, theData.Loc_respRT(n));
    end
elseif sSource == 2 % create logfiles for recog judgments only
    fid = fopen(saveName, 'wt');        %'wt' indicates write text mode; used for compatibility across text reading programs
    fprintf(fid, ('subjNum\ttrialonset\ttestitem\tstudyitem\tstudysession\tstudytrial\tstudypos\tstudytype\tcond\trecogresp\trecogRT\n'));
    for n = 1:trialcount    % '%f' for fixed point notation (nums), '%s' for characters
        fprintf(fid, '%f\t%f\t%f\t%f\t%s\t%s\t%f\t%f\t%f\t%s\t%s\t%s\t%f\n',...
        theData.sNum, theData.stimColor, theData.testType, theData.onset(n), theData.testitem{n}, theData.studyitem{n}, theData.studysess(n), theData.studytrial(n), ...
        theData.studypos(n), theData.studycolor{n}, theData.validityCond{n},theData.recogresp{n}, theData.recogrespRT(n));
    end
end

Screen('FillRect',Window,0);                                        %create blank screen to indicate end of block, 0=black
Screen('Flip',Window);                                              %draw blank screen
pause(2);                                                           %wait 2 seconds before displaying 'end of script' message

% Print a goodbye screen
DrawFormattedText(Window, 'End of this session\nPress any key to exit','center','center',255); 
Screen('Flip',Window);

pause;                                                              % wait for any keypress to close the screen
clear screen
ShowCursor;

cd(thePath.start);                                                  %return to main directory




