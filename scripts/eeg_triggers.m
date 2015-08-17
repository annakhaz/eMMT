% start timing/trigger
  NetStation('Connect', '10.0.0.42');
  WaitSecs(1);
  NetStation('StartRecording');
  WaitSecs(1);
  NetStation('Synchronize', 45);
  WaitSecs(1);

% TODO fig out how to update
NetStation('Event', ['STI' num2str(theData.oldNew(Trial))], theData.VBLTimestamp(Trial), .01); %1 = OLD;  2 = NEW;



theData.preSynchTime(Trial) = GetSecs;
NetStation('Synchronize', 45);
theData.postSynchTime(Trial) = GetSecs;
Screen(S.Window,'Flip');
    

NetStation('StopRecording');