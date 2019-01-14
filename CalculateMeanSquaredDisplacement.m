function MeanSquaredDisplacement = CalculateMeanSquaredDisplacement(B_Factor)
%% Summary
% description: Calculate Mean Squared Displacement from B-factor with equation: MSD = sqrt(B_factor/(8*pi^2))
% author: Jin.Dai
% date: 2014.05.09

MeanSquaredDisplacement = sqrt(B_Factor/(8*pi^2));

end

