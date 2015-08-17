
function [teststim, studystim, studysess, studytrial, studypos, studycolor, validityCond, studyjitter] = MU3ReadTestList(thePath,listName)
% Read the contents of the test lists, and store them in the
% return variables.
% JC 02/01/07

cd(thePath.stimlists);
raw = read_table([listName '.txt']);  % read the study list into some structs

% Now retrieve the list contents from "raw"
% We know what the contents will be because we made the listfile in excel
% Row 1 is the header row, so skip that
% Column 1 is the Trial Number, so we don't need that either



teststim	=	raw.col1	;
studystim	=	raw.col2	;
studysess	=	raw.col3	;
studytrial	=	raw.col4	;
studypos	=	raw.col5	;
studycolor	=	raw.col6	;
validityCond	=	raw.col7	;
studyjitter	=	raw.col8	;