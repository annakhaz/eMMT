
function [stsess, objCond, validityCond, LRcue, stimpos, stim, jitter, memCond,word,wordColor] = MU3ReadStudyList(thePath,listName)
% Read the contents of the study and test lists, and store them in the
% return variables.
% JC 02/01/07

cd(thePath.stimlists);
raw = read_table([listName '.txt']);  % read the study list into some structs

% Now retrieve the list contents from "raw"
% We know what the contents will be because we made the listfile in excel
% Row 1 is the header row, so skip that
% Column 1 is the Trial Number, so we don't need that either


stsess          = 	raw.col1	;
objCond         =	raw.col2	;
validityCond    =	raw.col3	;
LRcue           =	raw.col4	;
stimpos         =	raw.col5	;
stim            =	raw.col6	;
jitter          =	raw.col7	;
memCond         = 	raw.col8	;
word            = 	raw.col9	;
wordColor         = 	raw.col10	;