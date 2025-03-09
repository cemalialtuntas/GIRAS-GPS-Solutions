function [obsmat] = rinex3SNRreader(rinexobsfilename)
%--------------------------------------------------------------------------
% RINEX3SNRREADER
% This function reads version 3.xx rinex files and gives the SNR values
% with epochs.
%
% INPUT : rinexobsfilename    - Example: "TASH00UZB_R_20192030000_01D_30S_MO.rnx"
% OUTPUT: OBSMAT file
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
[fID] = fopen(rinexobsfilename, 'r');
if fID < 0
    error('Unable to open file named %s.\n\n', filename);
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
obsmat.info.rinexver = NaN;
obsmat.info.markername = '';
obsmat.info.rec_id = '';
obsmat.info.rec_type = '';
obsmat.info.rec_ver = '';
obsmat.info.ant_id = '';
obsmat.info.ant_type = '';
obsmat.info.approxpos = NaN(1,3);
obsmat.info.ant_dHdEdN = NaN(1,3);
obsG = cell(0); obsR = cell(0); obsE = cell(0); obsC = cell(0);
obsmat.info.typeofobs = cell(4,1); % ???
obsmat.info.typeofobsnum = NaN(4,1);  % ???
obsmat.info.interval = NaN;
obsmat.info.leapseconds = NaN;
obsmat.info.time_firstobs = NaN(1,6);
obsmat.info.time_lastobs = NaN(1,6);
obsmat.obs{2,1} = '';
cnt1 = 0;
cnt2 = 0;
cnt3 = 0;
cnt4 = 0;
cnt5 = 0;
flag1 = 0;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
t = struct('line',{});
iline = 0;
lines = fgets(fID);
obsmat.info.rinexver = str2double(lines(1:15));
if floor(obsmat.info.rinexver) ~= 3
    error('Unable to open file named %s.\n\n', filename);
end
    
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
    if (length(t(ind).line) > 70) &&...
            strcmp(strtrim(t(ind).line(61:end)),'MARKER NAME')
        obsmat.info.markername = strtrim(t(ind).line(1:60));
    end
    if (length(t(ind).line) > 78) &&...
            strcmp(strtrim(t(ind).line(61:end)),'REC # / TYPE / VERS')
        obsmat.info.rec_id = strtrim(t(ind).line(1:20));
        obsmat.info.rec_type = strtrim(t(ind).line(21:40));
        obsmat.info.rec_ver = strtrim(t(ind).line(41:60));
    end
    if (length(t(ind).line) > 71) &&...
            strcmp(strtrim(t(ind).line(61:end)),'ANT # / TYPE')
        obsmat.info.ant_id = strtrim(t(ind).line(1:20));
        obsmat.info.ant_type = strtrim(t(ind).line(21:60));
    end
    if (length(t(ind).line) > 78) &&...
            strcmp(strtrim(t(ind).line(61:end)),'APPROX POSITION XYZ')
        obsmat.info.approxpos = cell2mat(textscan(t(ind).line(1:60),...
            '%f %f %f'));
    end
    if (length(t(ind).line) > 78) &&...
            strcmp(strtrim(t(ind).line(61:end)),'ANTENNA: DELTA H/E/N')
        obsmat.info.ant_dHdEdN = cell2mat(textscan(t(ind).line(1:60),...
            '%f %f %f'));
    end
    if (length(t(ind).line) > 78) &&...
            strcmp(strtrim(t(ind).line(61:end)),'SYS / # / OBS TYPES')
        if strcmp(t(ind).line(1:4),'G   ')
            to_obs = textscan(t(ind).line(8:58),'%s');
            obsG =  [obsG; to_obs{1,1}];
            obsmat.info.typeofobsnum(1) = str2double(t(ind).line(5:6));
            flag1 = 1;
        elseif strcmp(t(ind).line(1:4),'R   ')
            to_obs = textscan(t(ind).line(8:58),'%s');
            obsR =  [obsR; to_obs{1,1}];
            obsmat.info.typeofobsnum(2) = str2double(t(ind).line(5:6));
            flag1 = 2;
        elseif strcmp(t(ind).line(1:4),'E   ')
            to_obs = textscan(t(ind).line(8:58),'%s');
            obsE =  [obsE; to_obs{1,1}];
            obsmat.info.typeofobsnum(3) = str2double(t(ind).line(5:6));
            flag1 = 3;
        elseif strcmp(t(ind).line(1:4),'C   ')
            to_obs = textscan(t(ind).line(8:58),'%s');
            obsC =  [obsC; to_obs{1,1}];
            obsmat.info.typeofobsnum(4) = str2double(t(ind).line(5:6));
            flag1 = 4;
        elseif strcmp(t(ind).line(1:6),'      ')
            if flag1 == 1
                to_obs = textscan(t(ind).line(8:58),'%s');
                obsG =  [obsG; to_obs{1,1}];
            elseif flag1 == 2
                to_obs = textscan(t(ind).line(8:58),'%s');
                obsR =  [obsR; to_obs{1,1}];
            elseif flag1 == 3
                to_obs = textscan(t(ind).line(8:58),'%s');
                obsE =  [obsE; to_obs{1,1}];
            elseif flag1 == 4
                to_obs = textscan(t(ind).line(8:58),'%s');
                obsC =  [obsC; to_obs{1,1}];
            end
        else
            flag1 = 0;
        end
    end
    if (length(t(ind).line) > 67) &&...
            strcmp(strtrim(t(ind).line(61:end)),'INTERVAL')
        obsmat.info.interval = str2double(t(ind).line(1:60));
    end
    if (length(t(ind).line) > 71) &&...
            strcmp(strtrim(t(ind).line(61:end)),'LEAP SECONDS')
        obsmat.info.leapseconds = str2double(t(ind).line(1:60));
    end
    if (length(t(ind).line) > 76) &&...
            strcmp(strtrim(t(ind).line(61:end)),'TIME OF FIRST OBS')
        obsmat.info.time_firstobs = cell2mat(textscan(t(ind).line(1:43),...
            '%f %f %f %f %f %f'));
    end 
    if (length(t(ind).line) > 76) &&...
            strcmp(strtrim(t(ind).line(61:end)),'TIME OF LAST OBS')
        obsmat.info.time_lastobs = cell2mat(textscan(t(ind).line(1:43),...
            '%f %f %f %f %f %f'));
    end 
end
obsmat.info.typeofobs = {obsG; obsR; obsE; obsC};
indS = cell(4,1);
obsmat.info.snrno = cell(4,1);
for ind = 1:4
    cnt5 = 0;
    for jind = 1:length(obsmat.info.typeofobs{ind,1})
        if strcmp(obsmat.info.typeofobs{ind,1}{jind}(1),'S')
            cnt5 = cnt5 + 1;
            if ~contains({obsmat.obs{2,:}},obsmat.info.typeofobs{ind,1}{jind}(1:3))
                cnt4 = cnt4 + 1;
                obsmat.obs{2,cnt4} = obsmat.info.typeofobs{ind,1}{jind}(1:3);
            end
            obsmat.info.snrno{ind}{cnt5,1} = obsmat.info.typeofobs{ind,1}{jind}(1:3);
            obsmat.info.snrno{ind}{cnt5,2} = find(strcmp(obsmat.info.typeofobs{ind,1}, ...
                obsmat.info.typeofobs{ind,1}{jind}(1:3)));
        end
    end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
for ind = lastheaderline + 1 : length(t)
    if length(t(ind).line) > 26 && strcmp(t(lastheaderline + 1).line(1:5),t(ind).line(1:5))
        cnt1 = cnt1 + 1;
        obsmat.info.epochs(cnt1,:) = cell2mat(textscan(t(ind).line(3:29),...
            '%f %f %f %f %f %f'));
        epochlines(cnt1) = ind;
        obsmat.info.epochsSEC(cnt1,1) = obsmat.info.epochs(cnt1,4)*60*60 + ...
                    obsmat.info.epochs(cnt1,5)*60 + obsmat.info.epochs(cnt1,6);
        obsmat.info.numofsat(cnt1,1) =  str2double(t(ind).line(34:35));
        obsmat.info.satno{cnt1,1} = NaN(obsmat.info.numofsat(cnt1),1);
    end
    t(ind).line = [t(ind).line, blanks(max(obsmat.info.typeofobsnum)*16+1 - ...
        length(t(ind).line))];
end
if isnan(obsmat.info.interval)
    obsmat.info.interval = obsmat.info.epochs(2,6) + 60*obsmat.info.epochs(2,5)+...
        3600*obsmat.info.epochs(2,4) - (obsmat.info.epochs(1,6)+ ...
        60*obsmat.info.epochs(1,5)+ 3600*obsmat.info.epochs(1,4));
end
for ind = 1:size(obsmat.obs,2)
    obsmat.obs{1,ind} = [NaN(length(obsmat.info.epochs),400) obsmat.info.epochsSEC];
end
for ind = 1 : length(epochlines)
    cnt2 = 0;
    for jind = 1 : obsmat.info.numofsat(ind)
        if strcmp(t(epochlines(ind) + jind).line(1),'G')
            for kind = 1 : size(obsmat.info.snrno{1},1)
                obsmat.obs{1,find(strcmp(obsmat.obs, ...
                    obsmat.info.snrno{1}{kind,1}))/2}(ind,str2double(t(epochlines(ind) + ...
                jind).line(2:3))) = str2double(t(epochlines(ind) + ...
                jind).line(4+(obsmat.info.snrno{1}{kind,2}-1)*16:18+...
                (obsmat.info.snrno{1}{kind,2}-1)*16-1));
            end
        elseif strcmp(t(epochlines(ind) + jind).line(1),'R')
            for kind = 1 : size(obsmat.info.snrno{2},1)
                obsmat.obs{1,find(strcmp(obsmat.obs, ...
                    obsmat.info.snrno{2}{kind,1}))/2}(ind,100+str2double(t(epochlines(ind) + ...
                jind).line(2:3))) = str2double(t(epochlines(ind) + ...
                jind).line(4+(obsmat.info.snrno{2}{kind,2}-1)*16:18+...
                (obsmat.info.snrno{2}{kind,2}-1)*16-1));
            end
        elseif strcmp(t(epochlines(ind) + jind).line(1),'E')
            for kind = 1 : size(obsmat.info.snrno{3},1)
                obsmat.obs{1,find(strcmp(obsmat.obs, ...
                    obsmat.info.snrno{3}{kind,1}))/2}(ind,200+str2double(t(epochlines(ind) + ...
                jind).line(2:3))) = str2double(t(epochlines(ind) + ...
                jind).line(4+(obsmat.info.snrno{3}{kind,2}-1)*16:18+...
                (obsmat.info.snrno{3}{kind,2}-1)*16-1));
            end
        elseif strcmp(t(epochlines(ind) + jind).line(1),'C')
            for kind = 1 : size(obsmat.info.snrno{4},1)
                obsmat.obs{1,find(strcmp(obsmat.obs, ...
                    obsmat.info.snrno{4}{kind,1}))/2}(ind,300+str2double(t(epochlines(ind) + ...
                jind).line(2:3))) = str2double(t(epochlines(ind) + ...
                jind).line(4+(obsmat.info.snrno{4}{kind,2}-1)*16:18+...
                (obsmat.info.snrno{4}{kind,2}-1)*16-1));
            end
        end
    end
end
for ind = 1:size(obsmat.obs,2)
    obsmat.obs{1,ind}(obsmat.obs{1,ind}(:,1:400) == 0) = NaN;
end
obsmat.info.DoY = [obsmat.info.epochs(1,1) day(datetime(obsmat.info.epochs(1,1),...
    obsmat.info.epochs(1,2),obsmat.info.epochs(1,3)),'dayofyear')];
%--------------------------------------------------------------------------
end

