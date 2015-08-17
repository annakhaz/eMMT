
function k = getEEGKeyboard

d=PsychHID('Devices');
k = 0;

for n = 1:length(d)
    if (strcmp(d(n).usageName,'Keyboard')) && (d(n).vendorID==1452) % EEG keyboard
        k = n;
        break
    end
end