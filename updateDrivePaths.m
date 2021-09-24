function updateDrivePaths
global REMORA
[xwavTableFile, xwavTablePath] = uigetfile('.mat', 'Select xwav table file to update', REMORA.savePath); %have user select xwav table to update

REMORA.savePath = xwavTablePath; % update default save path to last path selected

load(fullfile(xwavTablePath, xwavTableFile)); % load xwav table

inpaths = cell2mat(xwavTable.('inpath')); % convert current filepaths to string matrix
currentDrives = unique(inpaths(:,1)); % number of unique drive paths

for nd = 1:numel(currentDrives)
    drivePrompt{nd} = ['New drive path #', num2str(nd)];
end

drivePaths = inputdlg(drivePrompt, 'New Path(s) to Drive(s)'); % user input for paths to drives

for nd = 1:numel(drivePaths)
    Nx = find(inpaths(inpaths(:,1)=='H'));
    
    if length(drivePaths{nd})==1
        drivePaths{nd} = [drivePaths{nd}, ':\'];
    end
    
    for nx = Nx(1):Nx(end)
        oldPath = xwavTable.('inpath'){nx};
        newPath = [drivePaths{nd}, oldPath(4:end)];
        xwavTable.('inpath'){nx} = newPath;
    end
end

save(fullfile(xwavTablePath, xwavTableFile), 'xwavTable', 'deploymentName', 'rawFileStart');