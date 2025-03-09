function sat_index = find_sat_index(satname)

%--------------------------------------------------------------------------
% FINDSATINDEX FUNCTION
%
% INPUTS : satname
% OUTPUT : sat_index
%
% DATA CALLED:      * satellite_list.mat
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
load('satellite_list.mat');
%--------------------------------------------------------------------------
for i = 1:400
    if strcmp(satellite_list{i},satname)
        sat_index = i;
        break
    end
end
%--------------------------------------------------------------------------
end
