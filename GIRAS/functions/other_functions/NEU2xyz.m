function [xyz] = NEU2xyz(DnDeDu,lat,lon)
%--------------------------------------------------------------------------
% NEU2XYZ
% This function gives XYZ coordinates.
%
% INPUTS : DnDeDu (n x 3), lat (radians), lon (radians)
% OUTPUT : xyz (1 x 3)
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
xyz = ((R^-1)*DnDeDu')';
%--------------------------------------------------------------------------

