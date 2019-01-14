function R = Circle3D(Center, Radius, NormalVec, nPoint, plotSwitch)
%% CIRCLE3D
% return the coordinates of a circle in 3 dimension specified by center, radius and vector of normal plane.

%%
% switch of plot
if nargin < 5 || isempty(plotSwitch)
    plotSwitch = false;
end

% number of points
if nargin < 4 || isempty(nPoint)
    nPoint = 100;
end

%%
% basis orthogonal to NormalVec
Basis = null(NormalVec);

% parameter of circle
theta = linspace(0, 2*pi, nPoint+1)';
theta = theta(1:end-1);

% coordinates of cirle
R = Center + Radius*cos(theta)*Basis(:,1)' + Radius*sin(theta)*Basis(:,2)';

%%
if plotSwitch
    plot3(R(:,1), R(:,2), R(:,3), 'ro-')
    grid on;
    axis equal;
    rotate3d on;
    xlabel('x');
    ylabel('y');
    zlabel('z');
end

end

