function [Chi, Phi] = SphericalAngleInFrames(R,X,Y,Z)
%SPHERICALANGLEINFRAMES Summary of this function goes here
%   Detailed explanation goes here

% chi angle: polar angle, latitude
Chi = acos(diag(Z*R'));
% phi angle: azimuthal angle, longitude
ProjX = diag(X*R');
ProjY = diag(Y*R');
Phi = atan2(ProjY, ProjX);

end

