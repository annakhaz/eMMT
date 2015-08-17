
function [stsess, word, wordColor, distCond, dist, distPos, distCat, oldNew] = MMT_fMRIReadTestList(thePath,listName)
% Read the contents of the study and test lists, and store them in the
% return variables.
% JC 02/01/07

cd(thePath.stimlists);
raw = read_table([listName '.txt']);  % read the study list into some structs

% Now retrieve the list contents from "raw"
% We know what the contents will be because we made the listfile in excel
% Row 1 is the header row, so skip that
% Column 1 is the Trial Number, so we don't need that either


stsess       = 	raw.col1	;
word         =	raw.col2	;
wordColor    =	raw.col3	;
distCond     =	raw.col4	;
dist         =	raw.col5	;
distPos      =	raw.col6	;
distCat      =	raw.col7	;
oldNew       =	raw.col8	;