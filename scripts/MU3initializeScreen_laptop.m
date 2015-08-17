function [Window, Rect] = MU3initializeScreen_laptop

screenNumber = 0; % 0 = main monitor, 1 = second monitor
                           
[Window, Rect] = Screen('OpenWindow',screenNumber); % open the window

% Set fonts
Screen('TextFont',Window,'Times');      % font type (Times New Roman)
Screen('TextSize',Window,50);           % font size (36pt)
Screen('FillRect', Window, 0);          % screen color (0 = black)

HideCursor;                             % Remember to type ShowCursor later

