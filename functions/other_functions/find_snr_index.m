function snr_index = find_snr_index(snrmat,snrname)

%--------------------------------------------------------------------------
% FINDSNRINDEX FUNCTION
%
% INPUTS : snrmat, snrname
% OUTPUT : snr_index
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
for i = 1:length(snrmat.info.typesofsnr)
    if strcmp(snrmat.info.typesofsnr{i},snrname)
        snr_index = i;
        break
    end
end
%--------------------------------------------------------------------------
end
