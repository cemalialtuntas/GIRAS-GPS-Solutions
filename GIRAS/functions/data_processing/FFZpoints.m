function [n0e0u0, nPePuP, x0y0z0, xPyPzP, el_LLH, el_LLH_kmlcode, trackno] = FFZpoints(snrmat, snrtype, rh, elevang)
%--------------------------------------------------------------------------
% FFZPOINTS
% This function gives the coordinates to plot FFZ.
%
% INPUTS : * snrmat             : SNRMAT file
%          * snrtype            : SNR type
%          * rh                 : Reflector height
%          * elevang            : Elevation angle
% OUTPUT : * n0e0u0             : Local coordinates of the ellipse center
%          * nPePuP             : Local coordinates of the ellipse elements
%          * x0y0z0             : Global coordinates of the ellipse center
%          * xPyPzP             : Global coordinates of the ellipse elements
%          * el_LLH             : Ellipsodal coordinates of the ellipse elements
%          * el_LLH_kmlcode     : KML code section related to the ellipse
%          * trackno            : Number of satellite tracks
%
% FUNCTIONS CALLED: xyz2ell.m, refell.m, NEU2xyz.m, find_sat_index.m,
%                   find_WL
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
t = -pi:0.01:pi;
n0e0u0 = {}; nPePuP = {}; x0y0z0 = {}; xPyPzP = {};
trackno = 0;
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
xyz = snrmat.info.sitepos;
[lat, lon, ~] = xyz2ell(xyz(1),xyz(2),xyz(3));
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
for i = 1:length(snrmat.info.observedsats)
    j = 0;
    sat_index = find_sat_index(snrmat.info.observedsats{i});
    try WL = find_WL(sat_index,snrtype(1:2));
        dFFZ = rh/tand(elevang);
        aFFZ = sqrt(rh*WL*sind(elevang))/(sind(elevang)^2);
        bFFZ = sqrt(rh*WL*sind(elevang))/sind(elevang);
        azimangs = snrmat.ELAZ{sat_index}(elevang==round(snrmat.ELAZ{sat_index}(:,1)),2);
        idx = 1:length(azimangs);
        idx = [1 idx(abs(diff(azimangs)) > 5) length(azimangs)];
        for j = 1:length(idx)-1
            trackno = trackno + 1;
            azimang = mean(azimangs(idx(j):idx(j+1)));
            n0e0u0{i}{j} = [(dFFZ)*cosd(azimang) (dFFZ)*sind(azimang) -rh];
            eP = (n0e0u0{i}{j}(2) + (aFFZ*cos(t)*sind(azimang)) - (bFFZ*sin(t)*cosd(azimang)))';
            nP = (n0e0u0{i}{j}(1) + (aFFZ*cos(t)*cosd(azimang)) + (bFFZ*sin(t)*sind(azimang)))';
            uP = n0e0u0{i}{j}(3)*ones(length(nP),1);
            nPePuP{i}{j} = [nP eP uP];
            x0y0z0{i}{j} = xyz + NEU2xyz([n0e0u0{i}{j}],lat,lon);
            xPyPzP{i}{j} = xyz + NEU2xyz([nPePuP{i}{j}],lat,lon);
            [latell, lonell, hell] = xyz2ell(xPyPzP{i}{j}(:,1),xPyPzP{i}{j}(:,2),xPyPzP{i}{j}(:,3));
            el_LLH{i}{j} = [(180/pi)*[lonell latell] hell];
            el_LLH_kmlcode{i}{j} = '						';
            for k = 1:length(el_LLH{i}{j})
                el_LLH_kmlcode{i}{j} = [el_LLH_kmlcode{i}{j},num2str(el_LLH{i}{j}(k,1),'%1.13f'),',',...
                    num2str(el_LLH{i}{j}(k,2),'%1.13f'),',',num2str(el_LLH{i}{j}(k,3),'%1.13f'),' '];
            end
        end
    catch
    end
end
%--------------------------------------------------------------------------
end