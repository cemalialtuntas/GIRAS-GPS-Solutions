function [GPScoord] = compGPScoord(navmat, interval)
%--------------------------------------------------------------------------
% COMPGPSCOORD
% This function computes the coordinates of GPS satellites using NAVMAT
% file.
%
% INPUTS : navmat, interval
% OUTPUT : GPScoord
%
% DATE  : 30.04.2021
% E-MAIL: cemalialtuntas@gmail.com, cemali@yildiz.edu.tr
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
GPScoord = cell(1,32);
muG = 3.986005*10^14;
OMDOTe = 7.2921151467*10^-5;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
epochsdata = (0:interval:86400-interval)';
for i = 1:32
    if ~isempty(navmat.data(navmat.data(:,1)==i,:))
        navdata = navmat.data(navmat.data(:,1)==i,:);
        for j = 1:size(navdata,1)
            epochnav = navdata(j,2:7);
            daydiff = day(datetime(epochnav(1:3)),'dayofyear') - day(datetime(navmat.data(1,2:4)),'dayofyear');
            epochsec{i}(j,:) = [j daydiff*24*60*60 + epochnav(4)*60*60 + epochnav(5)*60 + epochnav(6)];
        end

        for k = 1:length(epochsdata)
            if isempty(epochsec{i}(epochsdata(k) >= epochsec{i}(:,2),1)) 
                ind = 1;
            else
                ind = epochsec{i}(epochsdata(k) >= epochsec{i}(:,2),1);
                ind = ind(1);
            end
            t = 86400*floor(navmat.data(1,19)/86400) + epochsdata(k);
            a = navdata(ind,18)^2;
            toe = navdata(ind,19);
            delta_n = navdata(ind,13);
            M0 = navdata(ind,14);
            ec = navdata(ind,16);
            om = navdata(ind,25);
            cus = navdata(ind,17); cuc = navdata(ind,15);
            crc = navdata(ind,24); crs = navdata(ind,12);
            cic = navdata(ind,20); cis = navdata(ind,22);
            i0 = navdata(ind,23); IDOT = navdata(ind,27);
            OM = navdata(ind,21); OMDOT = navdata(ind,26);
            n0 = sqrt(muG/(a^3));        
            tk = t - toe;
            if tk > 302400; tk = tk - 604800; elseif tk < -302400; tk = tk + 604800; end
            Mk = M0 + tk*(n0 + delta_n);
            Ek = Mk; dEk = 1;
            while dEk>1e-12
                Ek_old = Ek;
                Ek = Mk + ec*sin(Ek);
                dEk = rem(abs(Ek-Ek_old),2*pi);
            end
            f_k = atan2((sqrt(1-(ec^2))*sin(Ek)),(cos(Ek)-ec));
            Ek = acos((ec+cos(f_k))/(1+(ec*cos(f_k))));
            phi_k = f_k + om;
            duk = cuc*(cos(2*phi_k))+cus*(sin(2*phi_k));
            drk = crc*(cos(2*phi_k))+crs*(sin(2*phi_k));
            dik = cic*(cos(2*phi_k))+cis*(sin(2*phi_k));
            uk = phi_k + duk;
            rk = a*(1 - ec*cos(Ek)) + drk;
            ik = i0 + dik + tk*IDOT;
            xk = rk*cos(uk);
            yk = rk*sin(uk);
            OM_k = OM + tk*(OMDOT - OMDOTe) - OMDOTe*toe;
            xsat = xk*cos(OM_k) - yk*cos(ik)*sin(OM_k);
            ysat = xk*sin(OM_k) + yk*cos(ik)*cos(OM_k);
            zsat = yk*sin(ik);
            GPScoord{i}(k,:) = [epochsdata(k) xsat ysat zsat];
        end
    end
end
%--------------------------------------------------------------------------
end

