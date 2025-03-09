function [ephmat] = sp3reader(ephfilename)
%--------------------------------------------------------------------------
% SP3READER
% This function reads version precise ephemeris (sp3) files.
%
% INPUT : ephfilename    - Example: "igs20631.sp3"
% OUTPUT: EPHMAT file
%
% DATE  : 25.02.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
[fID] = fopen(ephfilename, 'r');
if fID < 0
    error('Unable to open file named %s.\n\n', filename);
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
ephmat.info.time_firstobs = NaN(1,6);
cnt1 = 0;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
t = struct('line',{});
iline = 0;
lines = fgets(fID);
ephmat.info.sp3ver = lines(1:2);
    
while ischar(lines)
    iline = iline + 1;
    t(iline).line = [lines, blanks(80 - length(lines))];
    lines = fgets(fID);
end
fclose(fID);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
for ind = 1 : length(t)
    if strcmp(t(ind).line(1:2),ephmat.info.sp3ver)
        ephmat.info.pvflag = t(ind).line(3);
        ephmat.info.time_firstobs = cell2mat(textscan(t(ind).line(4:31),...
            '%f %f %f %f %f %f'));
        ephmat.info.numofepochs = str2double(t(ind).line(32:39));
        ephmat.info.dataused = strtrim(t(ind).line(40:45));
        ephmat.info.coordsys = strtrim(t(ind).line(46:51));
        ephmat.info.orbtype = strtrim(t(ind).line(52:55));
        ephmat.info.agency = strtrim(t(ind).line(56:60));
    elseif strcmp(t(ind).line(1:2),'##')
        ephmat.info.gpsweek = str2double(t(ind).line(4:7));
        ephmat.info.secofweek = str2double(t(ind).line(8:23));
        ephmat.info.interval = str2double(t(ind).line(24:38));
    elseif strcmp(t(ind).line(1:2),'+ ') && ~strcmp(t(ind).line(4:6),'   ')
        ephmat.info.numofsats = str2double(t(ind).line(4:6));
    end
    if strcmp(t(ind).line(1:3),'*  ')
        cnt1 = cnt1 + 1;
        ephmat.info.epochs(cnt1,:) = cell2mat(textscan(t(ind).line(4:31),...
            '%f %f %f %f %f %f'));
        ephmat.info.epochsSEC(cnt1,1) = ephmat.info.epochs(cnt1,4)*60*60 + ...
            ephmat.info.epochs(cnt1,5)*60 + ephmat.info.epochs(cnt1,6);
        ephmat.products{cnt1,401} = ephmat.info.epochsSEC(cnt1);
    elseif strcmp(t(ind).line(1),'P')
        if strcmp(t(ind).line(2),'G')
            ephmat.products{cnt1,str2double(t(ind).line(3:4))} = ...
                cell2mat(textscan(t(ind).line(5:60),'%f %f %f %f'));
        elseif strcmp(t(ind).line(2),'R')
            ephmat.products{cnt1,100+str2double(t(ind).line(3:4))} = ...
                cell2mat(textscan(t(ind).line(5:60),'%f %f %f %f'));
        elseif strcmp(t(ind).line(2),'E')
            ephmat.products{cnt1,200+str2double(t(ind).line(3:4))} = ...
                cell2mat(textscan(t(ind).line(5:60),'%f %f %f %f'));
        elseif strcmp(t(ind).line(2),'C')
            ephmat.products{cnt1,300+str2double(t(ind).line(3:4))} = ...
                cell2mat(textscan(t(ind).line(5:60),'%f %f %f %f'));
        end
    end
end
ephmat.info.DoY = [ephmat.info.epochs(1,1) day(datetime(ephmat.info.epochs(1,1),...
    ephmat.info.epochs(1,2),ephmat.info.epochs(1,3)),'dayofyear')];
ephmat.info.time_firstobs = ephmat.info.epochs(1,:);
ephmat.info.time_lastobs = ephmat.info.epochs(end,:);
ephmat.info.epochsSEC = ephmat.info.epochsSEC - ephmat.info.epochsSEC(1);
for i = 1:size(ephmat.info.epochs,2)
    if ephmat.info.epochs(i,3) ~= ephmat.info.epochs(1,3)
        ephmat.products(i,:) = [];
    end
end
ephmat.info.epochsSEC = ephmat.info.epochsSEC(ephmat.info.epochs(:,3)==ephmat.info.epochs(1,3));
ephmat.products = ephmat.products(ephmat.info.epochs(:,3)==ephmat.info.epochs(1,3),:);
ephmat.info.epochs = ephmat.info.epochs(ephmat.info.epochs(:,3)==ephmat.info.epochs(1,3),:);
%--------------------------------------------------------------------------
end