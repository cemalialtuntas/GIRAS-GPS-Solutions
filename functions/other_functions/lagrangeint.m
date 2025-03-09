function [yout] = lagrangeint(xinp,yinp,xout)
%--------------------------------------------------------------------------
% LAGRANGEINT
% This function interpolates the data for desired points using the 
% Lagrange interpolation method.
%
% INPUTS : xinp (n x 1), yinp (n x 1), xout (m x 1)
% OUTPUT : yout (m x 1)
%
% FUNCTIONS CALLED: lagrangeloop.m
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
yout = NaN(length(xout),1); 
for i = 1:length(xout)
    if length(xinp) >= 10
        if length(xinp(xinp<xout(i)))>5
            if length(xinp(xinp>xout(i)))>5
                x1a = xinp(xinp<xout(i)); x1b = xinp(xinp>xout(i));
                y1a = yinp(xinp<xout(i)); y1b = yinp(xinp>xout(i));
                x1 = [x1a(end-4:end);x1b(1:5)]; y1 = [y1a(end-4:end);y1b(1:5)];
                yout(i,1) = lagrangeloop(x1,y1,xout(i));
            else
                x1 = xinp(end-9:end); y1 = yinp(end-9:end);
                yout(i,1) = lagrangeloop(x1,y1,xout(i));
            end
        else
            x1 = xinp(1:10); y1 = yinp(1:10);
            yout(i,1) = lagrangeloop(x1,y1,xout(i));
        end
    else
        yout(i,1) = lagrangeloop(xinp,yinp,xout(i));
    end
end
%--------------------------------------------------------------------------

end

