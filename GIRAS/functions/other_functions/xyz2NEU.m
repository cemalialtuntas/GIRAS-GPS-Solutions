function [NEU] = xyz2NEU(DxDyDz,lat,lon)
%--------------------------------------------------------------------------
% XYZ2NEU
% This function gives NEU coordinates.
%
% INPUTS : DxDyDz (1 x 3), lat (radians), lon (radians)
% OUTPUT : NEU (1 x 3)
%
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
R = [-cos(lon)*sin(lat) -sin(lon)*sin(lat) cos(lat);
     -sin(lon)          cos(lon)           0       ;
     cos(lon)*cos(lat)  sin(lon)*cos(lat)  sin(lat)];
NEU = R*DxDyDz';
%--------------------------------------------------------------------------

end

