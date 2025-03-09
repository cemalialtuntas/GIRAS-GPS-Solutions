function [snrmat] = createSNRMATfile(obsfile,ephfile,ephfiletype,XYZ)
%--------------------------------------------------------------------------
% CREATESNRMATFILE
% This function creates SNRMAT file.
%
% INPUTS : OBSMAT file, ephemeris mat file, ephfiletype (1:Nav, 2:SP3), XYZ (optional)
% OUTPUT : SNRMAT file
%
% FUNCTIONS CALLED: lagrangeint.m, lagrangeloop.m, xyz2ell.m, refell.m,
%                   xyz2NEU.m, compGPScoord.m
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
load('satellite_list.mat')
load(obsfile);
load(ephfile);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
if nargin < 4
    snrmat.info.sitepos = obsmat.info.approxpos;
else
    snrmat.info.sitepos = XYZ;
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
snrmat.info.markername = obsmat.info.markername;
snrmat.info.DoY = obsmat.info.DoY;
snrmat.info.typesofsnr = obsmat.obs(2,:)';
snrmat.info.interval = obsmat.info.interval;
snrmat.info.timeoffirstobs = obsmat.info.epochs(1,:);
snrmat.info.timeoflastobs = obsmat.info.epochs(end,:);
snrmat.snrdata = cell(1,400);
snrmat.ELAZ = cell(1,400);
outeph = NaN(length(obsmat.info.epochsSEC),1);
snrmat.info.epochs = [];
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
for i = 1:400
    key = 0;
    snrmat.snrdata{1,i} = NaN(length(obsmat.info.epochsSEC),length(snrmat.info.typesofsnr));
    for j = 1:size(obsmat.obs,2)
        if ~isempty(obsmat.obs{1,j}(~isnan(obsmat.obs{1,j}(:,i)),i))
            key = 1;
            snrmat.snrdata{1,i}(:,j) = obsmat.obs{1,j}(:,i);
            if isempty(snrmat.info.epochs)
                snrmat.info.epochs = obsmat.obs{1,j}(:,401);
            end
        end
    end
    if key == 0
        snrmat.snrdata{1,i} = [];
    end
end
if ephfiletype == 1
    GPScoord = compGPScoord(navmat,snrmat.info.interval);
    for i = 1:32
        if ~isempty(GPScoord{i})
            outeph = GPScoord{i}(:,2:4);
            [lat_site,lon_site,~] = xyz2ell(snrmat.info.sitepos(1),snrmat.info.sitepos(2),...
                snrmat.info.sitepos(3));
            for k = 1:size(outeph,1)
                NEU = xyz2NEU([outeph(k,1)-snrmat.info.sitepos(1) ...
                    outeph(k,2)-snrmat.info.sitepos(2) ...
                    outeph(k,3)-snrmat.info.sitepos(3)],lat_site,lon_site);
                EL = atan(NEU(3)/sqrt(NEU(1)^2+NEU(2)^2));
                EL(EL<0) = NaN;
                AZ = wrapTo2Pi(atan2(NEU(2),NEU(1)));
                snrmat.ELAZ{i}(k,:) = 180/pi*[EL AZ];
            end
        end
    end
else
    for i = 1:400
        if ~isempty(cell2mat(ephmat.products(:,i)))
            inpeph = 1000*cell2mat(ephmat.products(:,i));
            for j = 1:3
                outeph(:,j) = lagrangeint(cell2mat(ephmat.products(:,401)),...
                    inpeph(:,j),obsmat.info.epochsSEC);
            end
            [lat_site,lon_site,~] = xyz2ell(snrmat.info.sitepos(1),snrmat.info.sitepos(2),...
                snrmat.info.sitepos(3));
            for k = 1:size(outeph,1)
                NEU = xyz2NEU([outeph(k,1)-snrmat.info.sitepos(1) ...
                    outeph(k,2)-snrmat.info.sitepos(2) ...
                    outeph(k,3)-snrmat.info.sitepos(3)],lat_site,lon_site);
                EL = atan(NEU(3)/sqrt(NEU(1)^2+NEU(2)^2));
                EL(EL<0) = NaN;
                AZ = wrapTo2Pi(atan2(NEU(2),NEU(1)));
                snrmat.ELAZ{i}(k,:) = 180/pi*[EL AZ];
            end
        end
    end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
cnt1 = 0;
for i = 1:size(snrmat.snrdata,2)
    if ~isempty(snrmat.snrdata{1,i}) && ~isempty(snrmat.ELAZ{1,i})
        cnt1 = cnt1 + 1;
        snrmat.info.observedsats{cnt1,1} = satellite_list{i};
    end
end
%--------------------------------------------------------------------------

end