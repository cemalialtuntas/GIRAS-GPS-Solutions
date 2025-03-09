function [obsmat] = rinex2SNRreader(rinexobsfilename)
%--------------------------------------------------------------------------
% RINEX2SNRREADER
% This function reads version 2.xx rinex files and gives the SNR values
% with epochs.
%
% INPUT : rinexobsfilename    - Example: "laut2490.18o"
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
obsmat.info.typeofobs = cell(0);
obsmat.info.typeofobsnum = NaN;
obsmat.info.interval = NaN;
obsmat.info.leapseconds = NaN;
obsmat.info.time_firstobs = NaN(1,6);
cnt1 = 0;
cnt2 = 0;
cnt3 = 0;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
t = struct('line',{});
iline = 0;
lines = fgets(fID);
obsmat.info.rinexver = str2double(lines(1:15));
if floor(obsmat.info.rinexver) ~= 2
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
            strcmp(strtrim(t(ind).line(61:end)),'# / TYPES OF OBSERV')
        if isnan(obsmat.info.typeofobsnum)
            obsmat.info.typeofobsnum = str2double(t(ind).line(1:10));
        end
        to_obs = textscan(t(ind).line(11:60),'%s');
        obsmat.info.typeofobs = [obsmat.info.typeofobs;to_obs{1,1}];
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
end
cnt_SNRind = 0;
for ind_type = 1:length(obsmat.info.typeofobs)
    if strcmp(obsmat.info.typeofobs{ind_type}(1),'S')
        cnt_SNRind = cnt_SNRind + 1;
        SNRind{cnt_SNRind,1} = ind_type;
        SNRind{cnt_SNRind,2} = obsmat.info.typeofobs{ind_type};
    end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
for ind = lastheaderline + 1 : length(t)
    if length(t(ind).line) > 26 && strcmp(t(lastheaderline + 1).line(1:5),t(ind).line(1:5))
        cnt1 = cnt1 + 1;
        obsmat.info.epochs(cnt1,:) = [obsmat.info.time_firstobs(1) ...
            cell2mat(textscan(t(ind).line(5:26),...
            '%f %f %f %f %f'))];
        epochlines(cnt1) = ind;
        obsmat.info.epochsSEC(cnt1,1) = obsmat.info.epochs(cnt1,4)*60*60 + ...
                    obsmat.info.epochs(cnt1,5)*60 + obsmat.info.epochs(cnt1,6);
        obsmat.info.numofsat(cnt1) =  str2double(t(ind).line(30:32));
        obsmat.info.satno{cnt1,1} = NaN(obsmat.info.numofsat(cnt1),1);
    end
    t(ind).line = [t(ind).line, blanks(80 - length(t(ind).line))];
end
if isnan(obsmat.info.interval)
    obsmat.info.interval = obsmat.info.epochs(4,6) + 60*obsmat.info.epochs(4,5)+...
        3600*obsmat.info.epochs(4,4) - (obsmat.info.epochs(3,6)+ ...
        60*obsmat.info.epochs(3,5)+ 3600*obsmat.info.epochs(3,4));
end
for ind_obscells = 1:size(SNRind,1)
    obsmat.obs{1,ind_obscells} = [NaN(length(obsmat.info.epochs),400) obsmat.info.epochsSEC];
    obsmat.obs{2,ind_obscells} = SNRind{ind_obscells,2};
end
for ind = 1 : length(epochlines)
    cnt2 = 0;
    for jind = 0 : ceil(obsmat.info.numofsat(ind)/12) - 1
        control_2_10 = deblank(t(epochlines(ind) + jind).line);
        if strcmp(control_2_10(end-9:end),'.000000000')
            t(epochlines(ind) + jind).line = [control_2_10(1:end-10),'          '];
        end
        for kind = 0 : 3 : length(deblank(t(epochlines(ind) + jind).line)) - 35
            cnt2 = cnt2 + 1;
            if strcmp(t(epochlines(ind) + jind).line(kind+33),'G')
                obsmat.info.satno{ind}(cnt2,1) = str2double(t(epochlines(ind) + ...
                    jind).line(kind + 34 : kind + 35));
            elseif strcmp(t(epochlines(ind) + jind).line(kind+33),'R')
                obsmat.info.satno{ind}(cnt2,1) = 100 + str2double(t(epochlines(ind) + ...
                    jind).line(kind + 34 : kind + 35));
            elseif strcmp(t(epochlines(ind) + jind).line(kind+33),'E')
                obsmat.info.satno{ind}(cnt2,1) = 200 + str2double(t(epochlines(ind) + ...
                    jind).line(kind + 34 : kind + 35));
            elseif strcmp(t(epochlines(ind) + jind).line(kind+33),'C')
                obsmat.info.satno{ind}(cnt2,1) = 300 + str2double(t(epochlines(ind) + ...
                    jind).line(kind + 34 : kind + 35));
            else
                obsmat.info.satno{ind}(cnt2,1) = 350 + str2double(t(epochlines(ind) + ...
                    jind).line(kind + 34 : kind + 35));
            end
        end
    end
    for ind_obsdata = 1:size(SNRind,1)
        cnt3 = 0;
        for jind = epochlines(ind) + ceil(obsmat.info.numofsat(ind)/12) + ...
                ceil(SNRind{ind_obsdata,1}/5) - 1 : ceil(obsmat.info.typeofobsnum/5) : ...
                epochlines(ind) + (obsmat.info.numofsat(ind) - 1) * ...
                ceil(obsmat.info.typeofobsnum/5) - 1
            cnt3 = cnt3 + 1;
            if mod(SNRind{ind_obsdata,1},5) ~= 0
                obsmat.obs{1,ind_obsdata}(ind,obsmat.info.satno{ind}(cnt3,1)) = str2double(...
                t(jind).line(mod(SNRind{ind_obsdata,1},5)*16-15:mod(SNRind{ind_obsdata,1},5)*16-1));
            else
                obsmat.obs{1,ind_obsdata}(ind,obsmat.info.satno{ind}(cnt3,1)) = str2double(...
                t(jind).line(63:78));
            end
        end
    end
end

for i = 1:size(SNRind,1)
    obsmat.obs{1,i}(obsmat.obs{1,i}(:,1:400) == 0) = NaN;
end
obsmat.info.DoY = [obsmat.info.epochs(1,1) day(datetime(obsmat.info.epochs(1,1),...
    obsmat.info.epochs(1,2),obsmat.info.epochs(1,3)),'dayofyear')];
%--------------------------------------------------------------------------
end