function [dSNRdata] = create_dSNRdata(snrmat,satname,snrname,angEL,angAZ,poldeg)
%--------------------------------------------------------------------------
% CREATEDSNRDATA
% This function creates dSNR data for given inputs.
%
% INPUTS : * snrmat     : SNRMAT file
%          * angEL      : Elevation angle limits (1x2 double)
%          * angAZ      : Azimuth angle limits   (nx2 double)
%          * poldeg     : Polynomial degree      (double)
% OUTPUT : dSNR data  [epochs EL AZ SNR pfit dSNR normdSNR]
%
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
warning('off','all')
delcell = [];
dSNRdata = {};
sat_index = find_sat_index(satname);
snr_index = find_snr_index(snrmat,snrname);
snrdata = []; epochs = []; ELAZ = [];
bridgeV = [];
arcs = {}; tracks = {};
if ~isempty(snrmat.snrdata{1,sat_index}) && ~isempty(snrmat.ELAZ{1,sat_index})
    snrdataRaw = 10.^(snrmat.snrdata{1,sat_index}(:,snr_index)./20);
    epochs = snrmat.info.epochs;
    rownums = floor((epochs-epochs(1))./snrmat.info.interval) + 1;
    if sum(rownums>size(snrmat.ELAZ{1,sat_index},1)) == 0
        ELAZ = snrmat.ELAZ{1,sat_index}(rownums,:);
    else
        ELAZ = snrmat.ELAZ{1,sat_index};
    end
    snrdata = snrdataRaw(~isnan(snrdataRaw) & (ELAZ(:,1) > angEL(1)) & (ELAZ(:,1) < angEL(2)));
    epochs = epochs(~isnan(snrdataRaw) & (ELAZ(:,1) > angEL(1)) & (ELAZ(:,1) < angEL(2)));
    ELAZ = ELAZ(~isnan(snrdataRaw) & (ELAZ(:,1) > angEL(1)) & (ELAZ(:,1) < angEL(2)),:);
    for i = 1:size(angAZ,1)
        bridgeV = [bridgeV; [snrdata((ELAZ(:,2) > angAZ(i,1)) & (ELAZ(:,2) < angAZ(i,2))) ...
            epochs((ELAZ(:,2) > angAZ(i,1)) & (ELAZ(:,2) < angAZ(i,2))) ...
            ELAZ((ELAZ(:,2) > angAZ(i,1)) & (ELAZ(:,2) < angAZ(i,2)),:)]];
    end
    if ~isempty(bridgeV)
        [idx,idx] = unique(sort(bridgeV')','rows','stable');
        bridgeV = bridgeV(idx,:);
        snrdata = bridgeV(:,1); epochs = bridgeV(:,2); ELAZ = bridgeV(:,3:4);
    else
        snrdata = [];
    end
end
cnt1 = 0; cnt2 = 1;
cnt3 = 0; cnt4 = 0;
key = 'A';
stno = 0;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
if ~isempty(snrdata)
    for i = 1:length(snrdata)-1
        cnt1 = cnt1 + 1;
        arcs{cnt2}(cnt1,:) = [epochs(i) ELAZ(i,:) snrdata(i)];
        if (epochs(i+1)-epochs(i))/3600 > 2  % Min hour diff. set as 2h. 
            cnt2 = cnt2 + 1;
            cnt1 = 0;
        end
    end
end
for i = 1:length(arcs); if size(arcs{i},1) == 1; delcell = [delcell i]; end; end
if ~isempty(delcell); arcs(delcell) = []; end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
if ~isempty(arcs)
    for i = 1:length(arcs)
        cnt4 = cnt4 + 1;
        cnt3 = 0;
        if arcs{i}(2,2) < arcs{i}(1,2); key = 'D'; else; key = 'A'; end
        for j = 1:size(arcs{i},1)-1
            if strcmp(key,'A') && (arcs{i}(j+1,2) < arcs{i}(j,2))
                cnt3 = 1;
                cnt4 = cnt4 + 1;
                key = 'D';
            elseif strcmp(key,'D') && (arcs{i}(j+1,2) > arcs{i}(j,2))
                cnt3 = 1;
                cnt4 = cnt4 + 1;
                key = 'A';
            else
                cnt3 = cnt3 + 1;
            end
            tracks{1,cnt4}(cnt3,:) = arcs{i}(j,:);
            tracks{2,cnt4} = key;
        end
    end
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
if ~isempty(tracks)
    for i = 1:size(tracks,2)
        pfit = polyval(polyfit(sind(tracks{1,i}(:,2)),tracks{1,i}(:,4),poldeg),...
            sind(tracks{1,i}(:,2)));
        detrendedSNR = tracks{1,i}(:,4) - pfit;
        normdSNR = ((detrendedSNR - min(detrendedSNR))/(max(detrendedSNR) - min(detrendedSNR))) - 0.5;
        dSNRdata{1,i} = [tracks{1,i} pfit detrendedSNR normdSNR];
        dSNRdata{2,i} = tracks{2,i};
    end
end
%--------------------------------------------------------------------------

end