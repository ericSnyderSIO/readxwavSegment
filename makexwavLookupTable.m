function [xwavTable, rawFileStart, rawFileEnd, deploymentName] = makexwavLookupTable(drivePaths)

global PARAMS

xwavTable = table;
fig = uifigure;
for npath = 1:numel(drivePaths)
    
    drivePath = drivePaths{npath};
    if length(drivePath)==1
        drivePath = [drivePath, ':\'];
    end
    
    disks = dir(fullfile(drivePath, '*disk*')); % all disks on drive
   
    nx = 0; % xwav files counter
    
    for diskno = 1:numel(disks)
        
        PARAMS.inpath = fullfile(disks(diskno).folder, disks(diskno).name);
        
        progString = ['Processing ', PARAMS.inpath, '...'];
        
        dprog = uiprogressdlg(fig, 'Title', progString);
        
        xfiles = dir(fullfile(PARAMS.inpath, '*.x.wav'));
        
        for nxfile = 1:numel(xfiles)
            nx = nx + 1;
            PARAMS.infile = xfiles(nxfile).name;
            xwavTable.("inpath"){nx} = PARAMS.inpath;
            xwavTable.("infile"){nx} = PARAMS.infile;
            
            rdxwavhd
            
            dnum = PARAMS.start.dnum;
            
            xwavTable.("startTime")(nx) = dnum;
            
            rawFileStart{nx} = PARAMS.raw.dnumStart;
            rawFileEnd{nx} = PARAMS.raw.dnumEnd;
            dprog.Value = nxfile/numel(xfiles);
            
        end
        
        close(dprog)

        
    end
    

    
end
close(fig)
deploymentName = xwavTable.infile{1}(1:end-20);

% PARAMS.inpath = inpath;
% PARAMS.infile = infile;