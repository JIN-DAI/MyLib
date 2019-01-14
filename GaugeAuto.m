function [Angles, GaugeSites] = GaugeAuto(Angles)
%% GAUGEAUTO 
% Description: applying Z2 gauge-transformation automatically depending on
%              the condition that two consecutive torsion angles' difference 
%              should be less than \pi.
% Author: J.Dai
% Created Date: 2015.10.17
% Last Modified Date: 2017.10.19


%%
% check shape of Angles matrix
if size(Angles, 2) ~= 2
    Angles = Angles';
end
% torsion angles' difference
DiffTau = abs(Angles(2:end, 2) - Angles(1:end-1, 2));
% gauge-transformation condition
GaugeCriterion = pi; % default
%GaugeCriterion = 3*pi/4; % Sasha's
GaugeCondition = ~(isnan(DiffTau) | (DiffTau < GaugeCriterion));
% continue transformation until the condition is satisfied
GaugeSites = [];
while any(GaugeCondition)
    TempGaugeSites = find(GaugeCondition);
    GaugeSites = [GaugeSites; TempGaugeSites];
    for iG = 1:numel(TempGaugeSites)
        % gauge transformation at GaugeSites(iG)
        Angles = GaugeFromSite(Angles, TempGaugeSites(iG));
    end
    DiffTau = abs(Angles(2:end, 2) - Angles(1:end-1, 2));
    GaugeCondition = ~(isnan(DiffTau) | (DiffTau < GaugeCriterion));
end

end

