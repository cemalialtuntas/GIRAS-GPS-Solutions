function [P,f,pha] = lombGIRAS(dsnrdata,elev_ang,wL,hmax,prec)
%--------------------------------------------------------------------------
% LOMBGIRAS
% This function computes the Lomb Scargle Periodogram (LSP) and phase of 
% given data.
%
% INPUTS  : * dsnrdata   : dSNR data
%           * elev_ang   : Satellite elevation angles
%           * wL         : Wavelength of the GNSS signal
%           * hmax       : Maximum LSP grid frequency in meters
%           * prec       : The LSP frequency grid spacing in meters
% OUTPUTS : * f          : Frequencies
%           * P          : Spectral amplitude
%           * pha        : Phase
%
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

% Frequency and amplitude estimation --------------------------------------
[ofac, hifac] = get_ofac_hifac(elev_ang, wL/2, hmax, prec);
[f,P,~,~] = lomb(sind(elev_ang),dsnrdata,ofac,hifac);
%--------------------------------------------------------------------------

% PHASE ESTIMATION (Reference: Hocke K., 1998, Phase estimation with the
% Lomb-Scargle periodogram method, Annales Geophysicae.) ------------------
if ~isempty(P(~isnan(P)))
    f_dom = f(P==max(P));
    N = length(dsnrdata);
    w = 2*pi*f;
    wdom = 2*pi*f_dom(1);
    sine = sind(elev_ang);
    tave = (sine(1)+sine(end))/2;
    tau = (1./(2*wdom))*atan2(sum(sin(2*(wdom*(sine-tave)))),...
        sum(cos(2*(wdom*(sine-tave)))));
    a = (sqrt(2/N).*(sum(dsnrdata.*cos(wdom.*(sine-tave-tau)))))./...
        (sqrt(sum((cos(wdom.*(sine-tave-tau))).^2)));
    b = (sqrt(2/N).*(sum(dsnrdata.*sin(wdom.*(sine-tave-tau)))))./...
        (sqrt(sum((sin(wdom.*(sine-tave-tau))).^2)));
    phi = -atan2(b,a);
    phase_rad = wrapToPi(-(tave*w + tau*w - phi));
    pha = phase_rad*180/pi;
else
    pha = P;
end
%--------------------------------------------------------------------------

end