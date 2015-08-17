
function k = getKeyboardNumber_Anna()

% Determine the USB device number of the keyboard
% Janice Chen 02/01/06

d=PsychHID('Devices');
k = 0;

for n = 1:length(d)
    if strcmp(d(n).usageName,'Keyboard')&&d(n).productID == 610;
        k=n;
        break
    end
end