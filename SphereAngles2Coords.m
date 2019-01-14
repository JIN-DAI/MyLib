function Coords = SphereAngles2Coords(Angles)
%% SPHEREANGLES2COORDS 


%%
X = sin(Angles(:,1)).*cos(Angles(:,2));
Y = sin(Angles(:,1)).*sin(Angles(:,2));
Z = cos(Angles(:,1));

Coords = [X, Y, Z];

end

