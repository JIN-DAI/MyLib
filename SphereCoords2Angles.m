function Angles = SphereCoords2Angles(Coords)
%% SPHERECOORDS2ANGLES 


%%
X = [1, 0, 0];
Y = [0, 1, 0];
Z = [0, 0, 1];

theta = acos(Coords*Z');
phi = atan2(Coords*Y', Coords*X');

Angles = [theta, phi];

end

