function [navmat] = gpsNAVreader(navfilename)
%--------------------------------------------------------------------------
% GPSNAVREADER
% This function reads GPS navigation message files.
%
% INPUT : navfilename    - Example: "ab330010.16n"
% OUTPUT: NAVMAT file
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
[fID] = fopen(navfilename, 'r');
if fID < 0
    error('Unable to open file named %s.\n\n', filename);
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
navmat.info.rinexver = NaN;
navmat.info.type = '';
navmat.info.leapseconds = NaN;
navmat.info.ionalpha = [NaN NaN NaN NaN];
navmat.info.ionbeta = [NaN NaN NaN NaN];
navmat.info.A0 = NaN;
navmat.info.A1 = NaN;
navmat.info.reftime = NaN;
navmat.info.refweek = NaN;
navmat.info.DoY = [NaN NaN];
cnt1 = 0; 
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
t = struct('line',{});
iline = 0;
lines = fgets(fID);
while ischar(lines)
    iline = iline + 1;
    t(iline).line = lines;
    if strcmp(cellstr(t(iline).line(61:length(t(iline).line))),...
            'END OF HEADER')
        lastheaderline = iline;
    end
    lines = fgets(fID);
end
fclose(fID);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
for ind = 1 : lastheaderline
    if (length(t(ind).line) > 65) &&...
            strcmp(strtrim(t(ind).line(61:end)),'RINEX VERSION / TYPE')
        navmat.info.rinexver = str2double(t(ind).line(1:15));
        navmat.info.type = strtrim(t(ind).line(16:60));
    end
    if (length(t(ind).line) > 65) &&...
            strcmp(strtrim(t(ind).line(61:end)),'LEAP SECONDS')
        navmat.info.leapseconds = str2double(t(ind).line(1:60));
    end
    if (length(t(ind).line) > 65) &&...
            strcmp(strtrim(t(ind).line(61:end)),'ION ALPHA')
        navmat.info.ionalpha = cell2mat(textscan(t(ind).line(1:60),...
            '%f %f %f %f'));
    end
    if (length(t(ind).line) > 65) &&...
            strcmp(strtrim(t(ind).line(61:end)),'ION BETA')
        navmat.info.ionbeta = cell2mat(textscan(t(ind).line(1:60),...
            '%f %f %f %f'));
    end
    if (length(t(ind).line) > 65) &&...
            strcmp(strtrim(t(ind).line(61:end)),'DELTA-UTC: A0,A1,T,W')
        dUTCdata = cell2mat(textscan(t(ind).line(1:60),'%f %f %f %f'));
        navmat.info.A0 = dUTCdata(1);
        navmat.info.A1 = dUTCdata(2);
        navmat.info.reftime = dUTCdata(3);
        navmat.info.refweek = dUTCdata(4);
    end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
for ind = lastheaderline + 1 : length(t)
    if (length(t(ind).line) > 10) && ~strcmp(t(ind).line(1:2),'  ')
        cnt1 = cnt1 + 1;
        navmat.data(cnt1,1) = str2double(t(ind).line(1:2));
        epochline(cnt1,1) = ind;
    end
end
navmat.data(:,2:36) = NaN;
for ind_data = 1:length(epochline)
    navmat.data(ind_data,2:10) = [cell2mat(textscan(t(epochline(ind_data)).line(4:22),...
        '%f %f %f %f %f %f')) cell2mat(textscan(t(epochline(ind_data)).line(23:41),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)).line(42:60),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)).line(61:end),'%f'))];
    navmat.data(ind_data,11:14) = [cell2mat(textscan(t(epochline(ind_data)+1).line(4:22),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+1).line(23:41),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+1).line(42:60),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+1).line(61:end),'%f'))];
    navmat.data(ind_data,15:18) = [cell2mat(textscan(t(epochline(ind_data)+2).line(4:22),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+2).line(23:41),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+2).line(42:60),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+2).line(61:end),'%f'))];
    navmat.data(ind_data,19:22) = [cell2mat(textscan(t(epochline(ind_data)+3).line(4:22),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+3).line(23:41),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+3).line(42:60),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+3).line(61:end),'%f'))];
    navmat.data(ind_data,23:26) = [cell2mat(textscan(t(epochline(ind_data)+4).line(4:22),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+4).line(23:41),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+4).line(42:60),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+4).line(61:end),'%f'))];
    navmat.data(ind_data,27:30) = [cell2mat(textscan(t(epochline(ind_data)+5).line(4:22),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+5).line(23:41),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+5).line(42:60),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+5).line(61:end),'%f'))];
    navmat.data(ind_data,31:34) = [cell2mat(textscan(t(epochline(ind_data)+6).line(4:22),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+6).line(23:41),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+6).line(42:60),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+6).line(61:end),'%f'))];
    navmat.data(ind_data,35:36) = [cell2mat(textscan(t(epochline(ind_data)+7).line(4:22),'%f')) ...
        cell2mat(textscan(t(epochline(ind_data)+7).line(23:41),'%f'))];
end
navmat.data(:,2) = navmat.data(:,2) + 2000;
navmat.info.DoY = [median(navmat.data(:,2)) median(day(datetime(navmat.data(:,2:4)),'dayofyear'))];
%--------------------------------------------------------------------------
end