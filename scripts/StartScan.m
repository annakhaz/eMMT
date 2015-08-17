function [status, time0] = StartScan(pulseLength);
% StartScan - Starts the MR scanner by sending a pulse
%  [status, time0] = StartScan(pulseLength);
%             when error ocurred status will be non-zero
%             time0 is the time (GetSecs) when the onset of the pulse
%             started, used for syncing stimulus and MR time.
%
% Uses PMD-1208FS and Psychtoolbox. Pin 14 will give ~5V signal, pin 17
% can be used as a ground.
%
% 24-Jun-2005 SOD Ported to OSX - uses DAQ toolbox and the
%                 PMD-1208FS data acquisition device (daq).
%                 The PMD-1208FS is made by Measurement Computing.
%                 http://www.measurementcomputing.com/pmd.html
%
% 24-Feb-2006 JC Changed time0 to return clock rather than GetSecs
% 06/26/07 Changed back to GetSecs

% defaults
if nargin < 1 | isempty(pulseLength),
    pulseLength=0.001;
end;
status = 0; % unless we have problems

% Do we have a PMD-1208FS daq?
daq=DaqDeviceIndex;
if length(daq) == 0, % No we don't
    disp(sprintf(['[' mfilename ']:Sorry. Couldn''t find a PMD-1208FS box connected to your computer.\n' ... 
           'NOT RESPONDING? If PsychHID is not responding, e.g. after unplugging and\n' ...
           're-plugging the USB connector of your device, try quitting and restarting\n' ...
           'MATLAB. We find that this reliably restores normal communication.']));
    disp(sprintf(['[' mfilename ']:SCAN NOT STARTED!']));
    status = 1;
    time0  = GetSecs;
    return;
else, % Yes we do
    devices=PsychHID('Devices');
    d=devices(daq(1)); % use only first one if more connected
    disp(sprintf('[%s]:Found PMD-1208FS daq: device %d, serialNumber %s.',...
            mfilename,d.index,d.serialNumber));
end;

% Configuring digital ports for output
err=DaqDConfigPort(daq(1),1,0); % should be pin 14

% Make sure the PMD-1208FS is "attached". If not give a warning message.
% We may want to consider giving an error... 
if streq(err.name,'kIOReturnNotAttached')
    disp(sprintf(['[' mfilename ']:Mac OS error message says PMD-1208FS is "not attached".\n'...
          'If it is attached, we suggest that you quit and restart MATLAB.']));
    disp(sprintf(['[' mfilename ']:SCAN NOT STARTED!']));
    status = 1;
    time0  = GetSecs;
    return;
end

% get time0
time0 = GetSecs;
% time0 = clock;

% Send pulse
DaqAOut(daq(1),1,1);    % send pulse
WaitSecs(pulseLength);  % for a particular length, and then
DaqAOut(daq(1),1,0);    % reset

return;