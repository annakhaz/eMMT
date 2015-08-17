
function testBox;

% Test to ensure that keystrokes are being
% collected from both the button box in the scanner and from the laptop
% keyboard.
% JC 03/02/06

deviceNumber = getBoxNumber;
keyboardNumber = getKeyboardNumber;

% Laptop keyboard is not always deviceNumber=1
fprintf('Press any key on the laptop keyboard: ');
pause(0.05);
myStart = clock;
while 1
    [keyIsDown,secs,keyCode] = KbCheck(keyboardNumber);
    if keyIsDown
        keys = KbName(keyCode);
        RT = etime(clock,myStart);
        fprintf(['\nYou pressed ' num2str(keys) ' at ' num2str(RT) '\n']);
        while KbCheck(keyboardNumber)
        end
        break
    end
end
pause(1);
fprintf('\n');

% Buttonbox deviceNumber will vary depending on what order USB devices are
% plugged in
if deviceNumber ~= 0
    fprintf('Press any key on the button box: ');
    myStart = clock;
    while 1
        [keyIsDown,secs,keyCode] = KbCheck(deviceNumber);
        if keyIsDown
            keys = KbName(keyCode);
            RT = etime(clock,myStart);
            fprintf(['\nYou pressed ' num2str(keys) ' at ' num2str(RT) '\n']);
            fprintf(['Successful test. Thank you Nicole!\n']);
            while KbCheck(deviceNumber)
            end
            break
        end
    end
    fprintf('\n');
end