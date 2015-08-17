
% MMT script
% This script loads the paths for the experiment, and creates
% the variable thePath in the workspace.

pwd
thePath.start = pwd;

[pathstr,curr_dir] = fileparts(pwd); % AK: removed ,ext,versn to run on laptop
if ~strcmp(curr_dir,'MMT_eeg')
    fprintf(['You must start the experiment from the MMT_eeg directory. Go there and try again.\n']);
else
    thePath.scripts = fullfile(thePath.start, 'scripts');
    thePath.stim = fullfile(thePath.start, 'stim');
    thePath.stimObjs = fullfile(thePath.start, 'stim/objects/');
    thePath.stimFamFaces = fullfile(thePath.start, 'stim/famous_faces/');
    thePath.logfiles = fullfile(thePath.start, 'logfiles');
    thePath.stimlists = fullfile(thePath.start, 'stimlists');
    % add more dirs above

    % Add relevant paths for this experiment
    names = fieldnames(thePath);
    for f = 1:length(names)
        eval(['addpath(thePath.' names{f} ')']);
        fprintf(['added ' names{f} '\n']);
    end
    cd(thePath.scripts);
end
