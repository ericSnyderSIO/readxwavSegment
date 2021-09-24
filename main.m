function main(action)
%
% Main function for Remora. Takes the action user selects and runs
% appropriate functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS DATA REMORA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch action % which drop-down menu action was selected?
    case 'makeTable' % make a new table for a deployment
        fprintf('\n make xwav look-up table for a HARP\n')
        
        Ndrives = inputdlg('How many drive paths contain data for this HARP?', 'Number of Drives'); % User input for # of drives 
        
        xwavTable = table; % initialize table
        
        for nd = 1:str2num(Ndrives{1}) % make a user-input prompt for the number of drives  for this HARP
            drivePrompt{nd} = ['Drive path #', num2str(nd)];
        end
        
        drivePaths = inputdlg(drivePrompt, 'Path(s) to Drive(s)') % user input for paths to drives
        
        [xwavTable, rawFileStart, rawFileEnd, deploymentName] = makexwavLookupTable(drivePaths); % make the table
        
        
        savePath = uigetdir(REMORA.savePath, 'Save Table'); % user input for table save location
        REMORA.savePath = savePath; % updates default save path to last save path selected
        
        saveFilename = [deploymentName, '_xwavLookupTable']; % filename for table (based on deployment name)
        
        save(fullfile(REMORA.savePath, saveFilename), 'xwavTable', 'deploymentName', 'rawFileStart', 'rawFileEnd');
        
    case 'updateDrives'
        fprintf('\n update drive path in look-up table\n')
        updateDrivePaths
end