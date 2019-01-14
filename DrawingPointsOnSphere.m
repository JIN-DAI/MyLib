function DrawingPointsOnSphere(AxesHandle, Angles, GridLim, DrawType, ColorMap, ColorSwitch)
%% DrawingPointsOnSphere 
% Description: drawing angles' distribution on unit sphere
% Author: J.Dai
% Created Date: 2017.06.13
% Last Modified Date: 2017.07.18


%% Default Arguments
% AxseHandle
if nargin < 1 || isempty(AxesHandle)
    AxesHandle = [];
end
% Angles
if nargin < 2 || isempty(Angles)
    fprintf('Error: angle data is required!\n');
    return
end
% GridLim
if nargin < 3 || isempty(GridLim)
    GridLim = [0 pi; 0 2*pi];
end
% DrawType
if nargin < 4 || isempty(DrawType)
    DrawType = 'Density';
end
% ColorMap
if nargin < 5 || isempty(ColorMap)
    ColorMap = load('mycmap.mat');
end
% ColorSwitch
if nargin < 6 || isempty(ColorSwitch)
    ColorSwitch = 'Off';
end


%% print and start timer
% ------------------------------------------------------------------------- 
fprintf('Plotting Angles starts ...\n');
tic;


%%
% -------------------------------------------------------------------------
% Grid settings
GridNumber = [300, 150]; % number of grid of [polar angle, azimuthal angle]
Grid = {GridLim(1,1):pi/GridNumber(1):GridLim(1,2) GridLim(2,1):pi/GridNumber(2):GridLim(2,2)};

% n0
n0 = hist3(Angles, Grid);
switch DrawType
    case 'FreeEnergy'
        n0 = n0 + 1;
        n0 = n0./sum(n0(:)); % normalization to probability
        n0_Max = max(n0(:));
        n0 = log(n0_Max)-log(n0);
        % n1
        n1 = n0';
        n1(size(n0,1)+1, :) = max(n0(:));
        n1(:, size(n0,2)+1) = max(n0(:));
        % N
        N = transpose(n1);
    case 'Density'
        n1 = n0';
        n1( size(n0,1) + 1 ,size(n0,2) + 1 ) = 0; % NOTE: why???
        n2 = n1;
        if true
            for iRow = 1:size(n2,1)
                for iCol = 1:size(n2,2)
                    if n2(iRow,iCol) > 0
                        n2(iRow,iCol) = log(n1(iRow,iCol));
                        n2(iRow,iCol) = n2(iRow,iCol)^(1/1.3);
                    end
                end
            end
        end
        N = transpose(n2);
end


%% Drawing Background
% -------------------------------------------------------------------------
if isempty(AxesHandle)
    Figure.Name = 'Ditribution of angles on sphere';
    Figure.Posiotion = [300 10 800 800];
    Figure.Handle = figure('Position', Figure.Posiotion);
    set(Figure.Handle, 'Name', Figure.Name, 'FileName', Figure.Name);
    set(Figure.Handle, 'NumberTitle', 'off', 'Color', 'w');
    set(Figure.Handle, 'ToolBar', 'none');
    Axes = gca;
else
    Axes = AxesHandle;
end

set(Axes, 'NextPlot', 'add');
set(Axes, 'Box', 'off');

lighting phong;

[X, Y, Z] = sphere(size(N,1));

switch ColorSwitch
    case {'On', 'on'}
        colormap(ColorMap.mycmap);
    case {'Off', 'off'}
        colormap(rgb2gray(ColorMap.mycmap));
end

% [FaceAlpha EdgeAlpha]
SurfAlpha = [0.7 0]; %[0.7 0];
hSurf = surf(X, Y, Z, N,...
            'EdgeColor', 'y', 'FaceLighting', 'none',...
            'FaceAlpha', SurfAlpha(1), 'EdgeAlpha', SurfAlpha(2),...
            'FaceLighting', 'none', 'EdgeLighting', 'none');

set(hSurf, 'FaceLighting', 'none');

% %
[X2,Y2,Z2] = sphere(40);
hold on;
hMesh = mesh(X2*1.01, Y2*1.01, Z2*1.01, 'EdgeColor','black',...
    'FaceAlpha', 0, 'EdgeAlpha', 0.3, 'FaceLighting', 'none', 'EdgeLighting','none');

camlight('headlight');

arrow3D([0 0 0], [0 0 1.4], 'red', 0.9);
arrow3D([0 0 0], [0 1.5 0], 'blue', 0.9);
arrow3D([0 0 0], [1.5 0 0], 'green', 0.9);

text(0.2, 0.0, 1.3, 'z', 'FontSize', 50);
text(0.1, 1.7, 0.2, 'y', 'FontSize', 50);
text(1.7, 0.1, 0.2, 'x', 'FontSize', 50);

%xlim([-1, 2.5]);
%ylim([-1, 2.5]);
%zlim([-1, 1.5]);

set(gca, 'CLim', [min(N(:)) max(N(:))]);

set(Axes, 'Layer', 'top');
set(Axes, 'FontSize', 16);

%view(131, 52);
view(-48, -8);

freezeColors;

rotate3d on;
hold off;
axis equal;
axis off;
% Zoom figure
zoom(1.5);% NOTE: run this command independently!


%% stop timer and print
% -------------------------------------------------------------------------
Timer = toc;
fprintf('Plotting Angles completed!\n');
fprintf('Time cost: %.6f seconds.\n', Timer);
fprintf('\n');


end

