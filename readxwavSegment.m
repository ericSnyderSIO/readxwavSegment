function [data, t] = readxwavSegment(tstart, tend, xwavTable)
% reads in xwav data between tstart and tend, even if that spans multiple
% xwavs in a disk. Must be used after xwavTable is generated using
% readxwavSegment remora.
% tstart, tend, and t are in datenum format counting from year 2000 (i.e.
% 2018-Jun-01 12:00:00 is datenum([18, 06, 01, 12, 00, 00]) )


global PARAMS

nxStart = find(xwavTable.('startTime')<=tstart, 1, 'last');
nxEnd = find(xwavTable.('startTime')<=tend, 1, 'last');

numxwavs = nxEnd-nxStart + 1; % number of xwav files within time frame

switch numxwavs
    case 1 % data contained within 1 xwav file

        PARAMS.inpath = xwavTable.('inpath'){nxStart};
        PARAMS.infile = xwavTable.('infile'){nxStart};
        
        rdxwavhd
        
        dataType = ['int', num2str(PARAMS.nBits)]; % number of bits per sample
        
        % find which raw files I need:
        
        irawStart = find(PARAMS.raw.dnumStart<=tstart, 1, 'last'); % index of first raw file needed
        irawEnd = find(PARAMS.raw.dnumStart<=tend, 1, 'last'); % index of last raw file needed
        
        t = [];
        for iraw = irawStart:irawEnd
            NSampRaw = PARAMS.xhd.byte_length(iraw)/(PARAMS.samp.byte*PARAMS.nch); % number of samples in raw file = # of bytes in raw file/ (samples/byte * # of channels)
            traw = linspace(PARAMS.raw.dnumStart(iraw), PARAMS.raw.dnumEnd(iraw), NSampRaw);
            t = [t, traw];
        end
        
        itprior = find(t<=tstart); % indices of times prior to tstart
        t(itprior) = [];
        t(t>=tend) = [];
        
        nSampAfterRaw1 = length(itprior); % number of samples after first raw file to begin reading in data
        nBytesAfterRaw1 = nSampAfterRaw1*PARAMS.samp.byte*PARAMS.nch; % number of Bytes after first raw file to begin reading in data
        
        skip = PARAMS.xhd.byte_loc(irawStart) + nBytesAfterRaw1; % number of bytes to skip to begin reading in data
        
        fid = fopen(fullfile(PARAMS.inpath, PARAMS.infile), 'r');
        fseek(fid, skip, -1);
        data = fread(fid, [PARAMS.nch, length(t)], dataType);
        data = data.'; % transpose because all the filtering functions want it that way
        fclose(fid);
        
    case 2 % data spans 2 xwav files
        
        % ******** load in data from first xwav *****************
        PARAMS.inpath = xwavTable.('inpath'){nxStart};
        PARAMS.infile = xwavTable.('infile'){nxStart};
        
        rdxwavhd
        
        dataType = ['int', num2str(PARAMS.nBits)]; % number of bits per sample
        
        irawStart = find(PARAMS.raw.dnumStart<=tstart, 1, 'last');
        irawEnd = length(PARAMS.raw.dnumStart);

        t = [];
        for iraw = irawStart:irawEnd
            NSampRaw = PARAMS.xhd.byte_length(iraw)/(PARAMS.samp.byte*PARAMS.nch); % number of samples in raw file = # of bytes in raw file/ (samples/byte * # of channels)
            traw = linspace(PARAMS.raw.dnumStart(iraw), PARAMS.raw.dnumEnd(iraw), NSampRaw);
            t = [t, traw];
        end
        
        itprior = find(t<=tstart); % indices of times prior to tstart
        t(itprior) = [];
        
        nSampAfterRaw1 = length(itprior); % number of samples after first raw file to begin reading in data
        nBytesAfterRaw1 = nSampAfterRaw1*PARAMS.samp.byte*PARAMS.nch; % number of Bytes after first raw file to begin reading in data
        
        skip = PARAMS.xhd.byte_loc(irawStart) + nBytesAfterRaw1; % number of bytes to skip to begin reading in data
        
        fid = fopen(fullfile(PARAMS.inpath, PARAMS.infile), 'r');
        fseek(fid, skip, -1);
        datatemp = fread(fid, [PARAMS.nch, length(t)], dataType);
        datatemp = datatemp.'; % transpose because all the filtering functions want it that way
        fclose(fid);
                
        data = datatemp;
        
        % ******** load in data from second xwav *****************
        PARAMS.inpath = xwavTable.('inpath'){nxEnd};
        PARAMS.infile = xwavTable.('infile'){nxEnd};
        
        rdxwavhd
        
        dataType = ['int', num2str(PARAMS.nBits)]; % number of bits per sample
        
        % load in data form first xwav:
        irawStart = 1;
        irawEnd = find(PARAMS.raw.dnumStart<=tstart, 1, 'last');

        ttemp = [];
        for iraw = irawStart:irawEnd
            NSampRaw = PARAMS.xhd.byte_length(iraw)/(PARAMS.samp.byte*PARAMS.nch); % number of samples in raw file = # of bytes in raw file/ (samples/byte * # of channels)
            traw = linspace(PARAMS.raw.dnumStart(iraw), PARAMS.raw.dnumEnd(iraw), NSampRaw);
            ttemp = [ttemp, traw];
        end
        
        ttemp(ttemp>=tend) = [];
        
        skip = PARAMS.xhd.byte_loc(1); % number of bytes to skip to begin reading in data
        
        fid = fopen(fullfile(PARAMS.inpath, PARAMS.infile), 'r');
        fseek(fid, skip, -1);
        datatemp = fread(fid, [PARAMS.nch, length(ttemp)], dataType);
        datatemp = datatemp.'; % transpose because all the filtering functions want it that way
        fclose(fid);
                
        data = [data, datatemp];
        t = [t, ttemp];
        
    otherwise % data spans 3 or more xwav files. probably not a good idea to read this all in
        
        % ******** load in data from first xwav *****************
        PARAMS.inpath = xwavTable.('inpath'){nxStart};
        PARAMS.infile = xwavTable.('infile'){nxStart};
        
        rdxwavhd
        
        dataType = ['int', num2str(PARAMS.nBits)]; % number of bits per sample
        
        irawStart = find(PARAMS.raw.dnumStart<=tstart, 1, 'last');
        irawEnd = length(PARAMS.raw.dnumStart);

        t = [];
        for iraw = irawStart:irawEnd
            NSampRaw = PARAMS.xhd.byte_length(iraw)/(PARAMS.samp.byte*PARAMS.nch); % number of samples in raw file = # of bytes in raw file/ (samples/byte * # of channels)
            traw = linspace(PARAMS.raw.dnumStart(iraw), PARAMS.raw.dnumEnd(iraw), NSampRaw);
            t = [t, traw];
        end
        
        itprior = find(t<=tstart); % indices of times prior to tstart
        t(itprior) = [];
        
        nSampAfterRaw1 = length(itprior); % number of samples after first raw file to begin reading in data
        nBytesAfterRaw1 = nSampAfterRaw1*PARAMS.samp.byte*PARAMS.nch; % number of Bytes after first raw file to begin reading in data
        
        skip = PARAMS.xhd.byte_loc(irawStart) + nBytesAfterRaw1; % number of bytes to skip to begin reading in data
        
        fid = fopen(fullfile(PARAMS.inpath, PARAMS.infile), 'r');
        fseek(fid, skip, -1);
        datatemp = fread(fid, [PARAMS.nch, length(t)], dataType);
        datatemp = datatemp.'; % transpose because all the filtering functions want it that way
        fclose(fid);
                
        data = datatemp;
        
        
        % ******** load in data from middle xwavs ***************** 
        for nx = nxStart+1:nxEnd-1
            PARAMS.inpath = xwavTable.('inpath'){nx};
            PARAMS.infile = xwavTable.('infile'){nx};
            rdxwavhd
            
            dataType = ['int', num2str(PARAMS.nBits)]; % number of bits per sample
            
            irawStart = 1;
            irawEnd = length(PARAMS.raw.dnumStart);
            
            ttemp = [];
            for iraw = irawStart:irawEnd
                NSampRaw = PARAMS.xhd.byte_length(iraw)/(PARAMS.samp.byte*PARAMS.nch); % number of samples in raw file = # of bytes in raw file/ (samples/byte * # of channels)
                traw = linspace(PARAMS.raw.dnumStart(iraw), PARAMS.raw.dnumEnd(iraw), NSampRaw);
                ttemp = [ttemp, traw];
            end
            
            skip = PARAMS.xhd.byte_loc(1); % number of bytes to skip to begin reading in data
            
            fid = fopen(fullfile(PARAMS.inpath, PARAMS.infile), 'r');
            fseek(fid, skip, -1);
            datatemp = fread(fid, [PARAMS.nch, length(ttemp)], dataType);
            datatemp = datatemp.'; % transpose because all the filtering functions want it that way
            fclose(fid);
            
            data = [data, datatemp];
            t = [t, ttemp];
            
        end
        
        % ******** load in data from last xwav *****************
        PARAMS.inpath = xwavTable.('inpath'){nxEnd};
        PARAMS.infile = xwavTable.('infile'){nxEnd};
        
        rdxwavhd
        
        dataType = ['int', num2str(PARAMS.nBits)]; % number of bits per sample
        
        irawStart = 1;
        irawEnd = find(PARAMS.raw.dnumStart<=tstart, 1, 'last');

        ttemp = [];
        for iraw = irawStart:irawEnd
            NSampRaw = PARAMS.xhd.byte_length(iraw)/(PARAMS.samp.byte*PARAMS.nch); % number of samples in raw file = # of bytes in raw file/ (samples/byte * # of channels)
            traw = linspace(PARAMS.raw.dnumStart(iraw), PARAMS.raw.dnumEnd(iraw), NSampRaw);
            ttemp = [ttemp, traw];
        end
        
        ttemp(ttemp>=tend) = [];
        
        skip = PARAMS.xhd.byte_loc(1); % number of bytes to skip to begin reading in data
        
        fid = fopen(fullfile(PARAMS.inpath, PARAMS.infile), 'r');
        fseek(fid, skip, -1);
        datatemp = fread(fid, [PARAMS.nch, length(ttemp)], dataType);
        datatemp = datatemp.'; % transpose because all the filtering functions want it that way
        fclose(fid);
                
        data = [data, datatemp];
        t = [t, ttemp];
        
end

