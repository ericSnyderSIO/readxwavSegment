function [data, tout] = loadxwavSamples(inpath, infile, nstart, nend)
% Reads in data from sample nstart to sample nend from an xwav file.
% Uses most precise timing information available (raw file time stamps)
% Requires Triton to be in set path (https://github.com/MarineBioAcousticsRC/Triton)
% INPUTS:
% inpath = string vector path to xwav file 
%   e.g. inpath = 'E:\SOCAL_E_63_EE_C4_disk01';
% infile = string vector xwav file name
%   e.g. infile = SOCAL_E_63_EE_C4_180314_161500.x.wav';
% nstart = starting sample
% nend = ending sample
% OUTPUTS:
% data = [No. of samples] x [No. of Channels] matrix of acoustic data
% t1 = precise time stamp of first sample in data 
%   t1 is in datenum format minus 2000 years.
%   e.g. January 1st, 2015 at midnight is datenum([15, 01, 01, 00, 00, 00])


global PARAMS
PARAMS.ftype = 2;                                                           % indicate file is xwav

spd = 60*60*24;                                                             % seconds per day (for changing datenum to seconds)

PARAMS.inpath = inpath;
PARAMS.infile = infile;

rdxwavhd

% msg.num = 1;


% if (tstart - PARAMS.raw.dnumStart(1))*spd*PARAMS.fs < -1
%     msg.num = 0;
%     msg.str = 'tstart more than one sample prior to beginning of file';
%     msg.value = (PARAMS.raw.dnumStart(1) - tstart)*spd*PARAMS.fs;       % number of samples needed from previous xwav
%     tstart = PARAMS.raw.dnumStart(1);
% end

switch PARAMS.nBits
    case 16
        dataType = 'int16';
    case 32
        dataType = 'int32';
end

nSamples = round((tend-tstart)*spd*PARAMS.fs);                              % no. of samples to be read in

iraw = find(PARAMS.raw.dnumStart<=tstart, 1, 'last');                       % index of raw file time stamp immediatelty prior to tstart

rawFileByteLoc = PARAMS.xhd.byte_loc(iraw);                                 % number of bytes into the file that the raw file starts

nSampAfterRaw = round((tstart - PARAMS.raw.dnumStart(iraw))*spd*PARAMS.fs); % number of samples after raw file starts
bytesPerSample = PARAMS.samp.byte;                                          % number of samples per byte
nBytesAfterRaw = nSampAfterRaw*bytesPerSample*PARAMS.nch;                   % number of bytes after start of raw file to starting sample

% totalSamples = sum(PARAMS.xhd.byte_length/(bytesPerSample*PARAMS.nch));     % total number of samples in xwav file

skip = rawFileByteLoc + nBytesAfterRaw;                                     % number of bytes to skip ahead in file (past header and unneeded data)

% open file
fid = fopen(fullfile(inpath, infile), 'r');
fseek(fid, skip, -1);
[data, count] = fread(fid, [PARAMS.nch, nSamples], dataType);               
data = data.';                                                              % transpose because all the filtering functions want it that way
fclose(fid);

tout(1) = PARAMS.raw.dnumStart(iraw) + nSampAfterRaw/PARAMS.fs/spd;         % time stamp of first sample in data in datenum (minus 2000 years)
tout(2) = tout(1) + count/PARAMS.fs/spd;                                    % time stamp of last sample in data in datenum (minus 2000 years)

% if count < nSamples
%     msg = -1; % file ended before tend
% end