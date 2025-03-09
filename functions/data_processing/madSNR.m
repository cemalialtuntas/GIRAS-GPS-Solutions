function [mad,v,madresults] = madSNR(data,co)
%--------------------------------------------------------------------------
% MADSNR
% This function removes outliers using Median Absolute Deviation (MAD) method.
%
% INPUTS  : * data       : (nx1 double) Data
%           * co         : (double)     Coefficient
% OUTPUTS : * mad        : MAD value
%           * v          : Residuals
%           * madresults : Results
%
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
med_data = median(data(:,1));
v = med_data - data(:,1);
if median(abs(v)) == 0
    mad = 1.2533 * sum(abs(v))/size(v,1);
else
    mad = 1.4826 * median(abs(v));
end
madresults = data(abs(v) < co*mad,1);
%--------------------------------------------------------------------------
end