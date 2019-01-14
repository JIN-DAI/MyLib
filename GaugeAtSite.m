function AnglesGauged = GaugeAtSite(Angles, GaugeSite, SwitchMod2Pi)
%% GAUGEATSITE 
% Description:
% NOTE: Angles' indice must follow the notation used in curve3d.m and angles.m!
% Author: J.Dai
% Created Date: 2015.01.19
% Latest Modified Date: 2015.11.26


%% check arguments
% default mod final torsion into (-pi,pi]
if nargin < 3
    SwitchMod2Pi = true;
end

% check AnglesGauged's size to be Nx2
if size(Angles,2) ~= 2
    AnglesGauged = Angles';
    lt = 1;
else
    AnglesGauged = Angles;
    lt = 0;
end

% check GaugeSite in range
%if GaugeSite <= 1 || GaugeSite >= size(AnglesGauged,1)
if GaugeSite < 1 || GaugeSite > size(AnglesGauged,1)
    fprintf('WARNING: GaugeSite ''%d'' is out of bounds!\n', GaugeSite);
    GaugeSite = NaN;
end

%% gauge transformation at site
if ~isnan(GaugeSite)
    % transformation @GaugeSite
    AnglesGauged(GaugeSite, 1) = -AnglesGauged(GaugeSite, 1); % curvature = -curvature
    AnglesGauged(GaugeSite, 2) = AnglesGauged(GaugeSite, 2) - pi; % torsion = torsion - pi
    % transformation @GaugeSite+1
    if (GaugeSite+1) <= size(AnglesGauged,1)
        AnglesGauged(GaugeSite+1, 2) = AnglesGauged(GaugeSite+1, 2) + pi; % torsion = torsion + pi
    end
    if SwitchMod2Pi
        AnglesGauged(:,2) = Mod2Pi(AnglesGauged(:,2)); % mod gauged torsion into [-pi, pi]
    end
end


%% transpose if transposed in the beginning
if lt
    AnglesGauged = AnglesGauged';
end


end

