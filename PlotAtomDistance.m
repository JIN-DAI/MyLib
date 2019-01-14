function PlotAtomDistance(ResidueRange, AtomDist, MSD, XAxis, YAxis, PubSwitch)
%% PLOTATOMDISTANCE 
% description: plot atom distance and mean squared distance
% Author: J.Dai
% Created Date: 2014.05.09
% Last Modified Date: 2015.11.27

%% default arguments
% check operating system version
SYSTEM_VERSION = computer('arch');

%--- parameters depending on operating system ---
% setting opengl to use alpha value
if ~strcmp(SYSTEM_VERSION, 'maci64');    
    opengl software;
end

% figure position
switch SYSTEM_VERSION
    case 'maci64' % on MacOSX 
    FigurePosition = [40 25 1600 1000]; % for 21" MacPro, 1680x1050 
    %FigurePosition = [50,100,1200,800]; % for 15" MBP
    case {'win64', 'win32'} % on Windows, Resolution: 1366x768
    FigurePosition = [30, 50, 1300, 650];
    case 'glnxa64' % on Linux, Resolution: 1280x1024
    FigurePosition = [200, 300, 1200, 800];
end

% PubSwitch
if nargin < 6
    PubSwitch = 1;
end

% YLim & YTick
if nargin < 5 || isempty(YAxis)
    YAxis = [0 2.5 0.5];
elseif length(YAxis) == 2
    YAxis = [YAxis 0.5];
end
YLim = [YAxis(1) YAxis(2)];
YStep = YAxis(3);
YTick = [];
YTickPos = YLim(1):YStep:YLim(2); %[0 ceil(max([NMR.meanAtomDist+NMR.stdAtomDist Simulation.meanAtomDist+Simulation.stdAtomDist]))]
for i = 1:length(YTickPos)
    if abs(YTickPos(i)) < eps
        YTick{i} = ['$' num2str(YTickPos(i)) '$'];
    else
        YTick{i} = ['$' num2str(YTickPos(i), '%3.1f') '$'];
    end
end

% XLim & XTick
if nargin < 4 || isempty(XAxis)
    XAxis = [8 38 5]; % this is default for 2L86_chainA_model1_9_36
elseif length(XAxis) == 2
    XAxis = [XAxis 5];
end
XLim = [XAxis(1) XAxis(2)];
XStep = XAxis(3);
XTick = [];
XTickPos = ceil(XLim(1)/XStep)*XStep:XStep:floor(XLim(2)/XStep)*XStep; % [ResidueRange(1)-1:5:ResidueRange(end)+2];    
for i = 1:length(XTickPos)
    XTick{i} = ['$' num2str(XTickPos(i)) '$']; %ResidueRange        
end

% check AtomDist array size: 1xN
if size(AtomDist, 1) ~= 1
    AtomDist = AtomDist';
end

% check ResidueRange array size: 1xN
if size(ResidueRange, 1) ~= 1
    ResidueRange = ResidueRange';
end

%% --- plot ---
MarkerSizePlot = 10;
LineWidthPlot = 3;

FluctuationDist = 0.15;
if ~strcmp(SYSTEM_VERSION, 'maci64');
    FluctuationColor = 0.3*[1 1 1];
    FluctuationAlpha = 0.3;
else
    FluctuationColor = 0.7*[1 1 1];
    FluctuationAlpha = 1;
end

% plot settings for atom distance
AtomDistColor = 'k';
AtomDistMarker = 'o';
AtomDistLine = '-';
AtomDistFaceColor = AtomDistColor;

% plot settings for mean squared distance
MSDColor = 'r';
MSDMarker = '*';
MSDLine = '--';
MSDFaceColor = MSDColor;

% figure
figure('Position', FigurePosition, 'Color', 'w', 'NumberTitle', 'off', 'ToolBar', 'none');
set(gcf, 'Name', 'Atom Distance and Mean Squared Displacement');
set(gcf, 'FileName', 'Atom Distance and Mean Squared Displacement');
% hold on axis
haxes0 = gca;
set(haxes0, 'NextPlot', 'add');

switch 1
    case 1 % atom distance with fluctuation in shading
        % -fluctuation
        ShadeUpper = AtomDist+FluctuationDist;
        ShadeLower = AtomDist-FluctuationDist;
        ShadeLower(ShadeLower < 0) = 0;
        FaceEdgeX = [ResidueRange fliplr(ResidueRange) ResidueRange(1)];
        FaceEdgeY = [ShadeUpper, fliplr(ShadeLower) ShadeUpper(1)];
        hface = fill(FaceEdgeX, FaceEdgeY, FluctuationColor);
        set(hface, 'FaceAlpha', FluctuationAlpha);
        set(hface, 'LineStyle', 'none');
        % -atom distance
        hlineAD = plot(ResidueRange, AtomDist, [AtomDistColor AtomDistMarker AtomDistLine], ...
                       'LineWidth', LineWidthPlot, 'MarkerSize', MarkerSizePlot, 'MarkerFaceColor', AtomDistFaceColor); 
    case 2 % atom distance with fluctuation in errorbar
        % atom distance
        ShadeUpper = FluctuationDist*ones(1, length(AtomDist));
        ShadeLower = ShadeUpper;
        ShadeLower((AtomDist-ShadeLower)<0) = AtomDist((AtomDist-ShadeLower)<0);
        herrorbar = errorbar(ResidueRange, AtomDist, ShadeLower, ShadeUpper);
        set(herrorbar, 'Color', AtomDistColor, 'Marker', AtomDistMarker, 'LineStyle', AtomDistLine);
        set(herrorbar, 'LineWidth', LineWidthPlot, 'MarkerSize', MarkerSizePlot, 'MarkerFaceColor', AtomDistFaceColor);
        % fluctuation: bars
        hbar = get(herrorbar, 'Children');
        set(hbar(2), 'Color', 'r');
end

           
% axis 
set(haxes0, 'FontName', 'Helvetica', 'Box', 'on');
set(haxes0, 'XLim', XLim, 'YLim', YLim);
set(haxes0, 'XGrid', 'off', 'YGrid', 'off');
set(haxes0, 'XColor', 'k', 'YColor', 'k', 'LineWidth', 3);
set(haxes0, 'TickDir', 'in', 'TickLength', [.02 .02]);
set(haxes0, 'XMinorTick', 'off', 'YMinorTick', 'on');


% mean squared displacement
if ~isempty(MSD) && any(MSD)
    hlineMSD = plot(ResidueRange, MSD, [MSDColor MSDMarker MSDLine], ...
                    'LineWidth', LineWidthPlot, 'MarkerSize', MarkerSizePlot, 'MarkerFaceColor', MSDFaceColor);
end

% tick font
TickFontSize = 26;
TickFontWeight = 'Bold';
% label font
LabelFontSize = 26;
LabelFontWeight = 'Normal';

switch 1
    case 1
        %------------------------------------------------------------------
        % use text to set ticks
        % x ticks
        for i = 1:length(XTickPos)
            XTick{i} = num2str(XTickPos(i));
        end
        set(gca, 'XTick', XTickPos, 'XTickLabel', XTick);
        set(gca, 'FontSize', TickFontSize, 'FontWeight', TickFontWeight);
        % y ticks
        for i = 1:length(YTickPos)
            YTick{i} = num2str(YTickPos(i));
        end
        set(gca, 'YTick', YTickPos, 'YTickLabel', YTick);
        set(gca, 'FontSize', TickFontSize, 'FontWeight', TickFontWeight);
        
        % labels
        if ~PubSwitch
            % x labels
            hXLabel = xlabel('RESIDUE', 'FontSize', LabelFontSize, 'FontWeight', LabelFontWeight);
            % y labels
            %hYLabel = ylabel('Angstroms', 'FontSize', LabelFontSize, 'FontWeight', LabelFontWeight);
            YLabelPosRatio = [0.5 0.5];
            hYLabelText = text(XLim(1)-YLabelPosRatio(1)*(XTickPos(2)-XTickPos(1)), ...
                               YLim(1)+(YLim(2)-YLim(1))*YLabelPosRatio(2), ...
                               '$\bf{\AA}ngstr\ddot{o}m$', 'Interpret', 'latex', ...
                               'Rotation', 90);
            set(hYLabelText, 'FontSize', LabelFontSize+6, 'FontWeight', LabelFontWeight);
            set(hYLabelText, 'HorizontalAlignment', 'Center');
        end
        %------------------------------------------------------------------
    case 2
        %------------------------------------------------------------------
        % use format_ticks to set ticks
        format_ticks(haxes0, XTick, YTick, XTickPos, YTickPos, 0, 0, [], 'FontSize', TickFontSize+4, 'FontWeight', TickFontWeight);
        
        if ~PubSwitch
            % labels
            hXLabel = xlabel({'';'RESIDUE'}, 'FontSize', LabelFontSize, 'FontWeight', LabelFontWeight);
            %set(hXLabel, 'Color', 'k', 'Position', [(XLim(1)+XLim(end))/2 -0.24 1]);
            hYLabel = ylabel({'Angstroms';'';''}, 'FontSize', LabelFontSize, 'FontWeight', LabelFontWeight);
            %set(hYLabel, 'Color', 'k', 'Position', [XLim(1)-2 (YLim(1)+YLim(end))/2 1]);
        end
        %------------------------------------------------------------------
end

end

