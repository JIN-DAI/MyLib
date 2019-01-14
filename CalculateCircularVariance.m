function CircularVariance = CalculateCircularVariance(CircularVariables)
%% CALCULATECIRCULARVARIANCE
% Description: calculate circular variance
% Author: Jin Dai
% Created Date: 2017.06.08
% Last Modified Date: 2017.06.08
% NOTE: need to test!!!

%%
CircularVariables = CheckCoordsDim(CircularVariables,1);

R = sqrt(sum(cos(CircularVariables))^2 + sum(sin(CircularVariables))^2);

CircularVariance = 1-R/numel(CircularVariables);


end

