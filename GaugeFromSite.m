function AnglesGauged = GaugeFromSite(Angles, GaugeSite, SwitchMod2Pi)
%% GAUGEFROMSITE Summary 
% Description:
% Author: J.Dai
% Created Date: 2015.01.20
% Latest Modified Date: 2015.11.26

% default mod final torsion into (-pi,pi]
if nargin < 3
    SwitchMod2Pi = true;
end

%% call GaugeAtSite() from GaugeSite to the end
AnglesGauged = Angles;
%for i = GaugeSite:length(AnglesGauged)-1
for i = GaugeSite:length(AnglesGauged)
    AnglesGauged = GaugeAtSite(AnglesGauged, i, SwitchMod2Pi);
end


end

