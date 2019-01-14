function FoldingIndex = CalculateFoldingIndex(Torsion)
%% CALCULATEFOLDINGINDEX
% Description: Torsion should be in the interval of (-pi, pi]
% Author: J.Dai
% Created Date: 2015.03.18
% Last Modified Date: 2015.03.18


%% Calculation part
% omit NaN value in Torsion
Tau = Torsion(~isnan(Torsion));
% initialize FoldingIndex
FoldingIndex = 0;
% calculate site by site
for i = 2:length(Tau)
    TempF = Tau(i)-Tau(i-1);
    if TempF > pi
        TempF = TempF - 2*pi;
    elseif TempF < -pi
        TempF = TempF + 2*pi;
    end;
    %FoldingIndex = FoldingIndex - TempF; % ?- or +
    FoldingIndex = FoldingIndex + TempF; % NOTE!!!!!
end
% normalize FoldingIndex
FoldingIndex = FoldingIndex/pi;


end

