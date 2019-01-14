function [VecUnit, VecLength] = UnitVecByRow(Vec)
%NORMBYROW Summary of this function goes here
%   Detailed explanation goes here

VecLength = sqrt(diag(Vec*Vec'));

VecUnit = Vec./repmat(VecLength, 1, 3);

end

