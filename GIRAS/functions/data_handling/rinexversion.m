function [obsmat] = rinexversion(rinexobsfilename)
%--------------------------------------------------------------------------
% RINEXVERSION
% This function finds the version of input rinex file and calls the
% appropriate rinex reader function.
%
% INPUT : rinexobsfilename    - Example: "laut2490.18o"
% OUTPUT: OBSMAT file
%
% DATE  : 24.02.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
[fID] = fopen(rinexobsfilename, 'r');
if fID < 0
    error('Unable to open file named %s.\n\n', filename);
end
%--------------------------------------------------------------------------
lines = fgets(fID);
obsmat.info.rinexver = str2double(lines(1:15));
if floor(obsmat.info.rinexver) == 2
    obsmat = rinex2SNRreader(rinexobsfilename);
    obsmat.info.time_firstobs = obsmat.info.epochs(1,:);
    obsmat.info.time_lastobs = obsmat.info.epochs(end,:);
elseif floor(obsmat.info.rinexver) == 3
    obsmat = rinex3SNRreader(rinexobsfilename);
    obsmat.info.time_firstobs = obsmat.info.epochs(1,:);
    obsmat.info.time_lastobs = obsmat.info.epochs(end,:);
end

%--------------------------------------------------------------------------
fclose(fID);
end