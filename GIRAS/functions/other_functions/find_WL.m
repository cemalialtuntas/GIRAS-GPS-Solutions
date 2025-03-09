function WL = find_WL(sat_index,snrtype)

%--------------------------------------------------------------------------
% FINDWL FUNCTION
%
% INPUTS : * sat_index  - Satellite index
%          * snrtype    - SNR observation type
% OUTPUT : * WL         - Wavelength (in meters)
%
% DATA CALLED:      * wavelengths.mat
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
load('wavelengths.mat');
%--------------------------------------------------------------------------
if sat_index < 100
    for i = 1:length(wavelengths.GPS)
        if strcmp(snrtype,wavelengths.GPS{i,1})
            WL = wavelengths.GPS{i,3};
            break
        end
    end
elseif sat_index < 200
    for i = 1:length(wavelengths.GLONASS)
        if strcmp(snrtype,wavelengths.GLONASS{i,1})
            WL = wavelengths.GLONASS{i,2}(sat_index-100,3);
            break
        end
    end
elseif sat_index < 300
    for i = 1:length(wavelengths.GALILEO)
        if strcmp(snrtype,wavelengths.GALILEO{i,1})
            WL = wavelengths.GALILEO{i,3};
            break
        end
    end
elseif sat_index < 400
    for i = 1:length(wavelengths.BEIDOU)
        if strcmp(snrtype,wavelengths.BEIDOU{i,1})
            WL = wavelengths.BEIDOU{i,3};
            break
        end
    end
else
    for i = 1:length(wavelengths.LIST)
        if strcmp(snrtype,wavelengths.LIST{i,1})
            WL = wavelengths.LIST{i,3};
            break
        end
    end
end
%--------------------------------------------------------------------------
end
