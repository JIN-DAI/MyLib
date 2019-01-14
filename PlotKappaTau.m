function PlotKappaTau(Kappa, Tau, IndexOffset, XLim, FigureName, FigureHandle, ResidueTickStep, XMinorTick, PubSwitch, LegendString)
%% PLOTKAPPATAU
% Description: plot experiment segment's angles-{kappa, tau}, kappa for curvature and tau for torsion.
% Author: Jin Dai
% Created Date: 2015.01.19
% Latest Modified Date: 2015.01.20


%% default settings
if nargin < 10
    % default legend string for pub
    LegendString = [];
end

if nargin < 9 || isempty(PubSwitch)
    % publish switch to close legend and axis labels
    PubSwitch = 1;
end

if nargin < 8 || isempty(XMinorTick)
    % switch to show x minor tick
    XMinorTick = 'on';
end

if nargin < 7 || isempty(ResidueTickStep)
    ResidueTickStep = 5; % Step length between each tick
end

if nargin < 6 || isempty(FigureHandle)
    myfigure = figure; % create new figure handle
else
    myfigure = FigureHandle; % copy figure handle
end

if nargin < 5 || isempty(FigureName)
    % figure's name
    FigureName = 'Residue Number v.s. Angles';
end

if nargin < 4 || isempty(XLim)
    % axes X-Limit
    XLim = [IndexOffset IndexOffset+length(Kappa)+2];
end

% check operating system version
SYSTEM_VERSION = computer('arch');


%% figure parameters settings
% line and marker color
% kappa
kappaColor = 'r'; %[1 0 0]; %[1 0 1]; %[0. 0.6 0]; 
kappaColorF = kappaColor;
% tau
tauColor = 'b'; %'k'; %[0 0 1]; %[0 1 1]; %[0.2 0.8 0.8]; 
tauColorF = tauColor;

% figure position
FigurePosition = CreateFigurePosition(SYSTEM_VERSION);
% -------------------------------------------------------------------------
% switch SYSTEM_VERSION
%     case 'maci64' % on MacOSX 
%     FigurePosition = [40 25 1600 1000]; % for 21" MacPro, 1680x1050 
%     %FigurePosition = [50,100,1200,800]; % for 15" MBP
%     case {'win64', 'win32'} % on Windows, Resolution: 1366x768
%     FigurePosition = [30, 50, 1300, 650];
%     case 'glnxa64' % on Linux, Resolution: 1280x1024
%     FigurePosition = [200, 300, 1200, 800];
% end
% -------------------------------------------------------------------------

switch 1
    case 0
        % line width
        LineWidth = [6 6]; %[5 5]; %[kappa tau]
        % marker size
        MarkerSize = 12;
    case 1
        % line width
        LineWidth = [4 4];
        % marker size
        MarkerSize = 9;
end

% line type
LineType = [{'-'}, {'-'}]; %[kappa tau]
% marker type
MarkerType = ['o', 'o']; %[kappa tau]

% x-label and y-label font size
switch SYSTEM_VERSION
    case 'maci64' % on MacOSX 
    LabelFontSize = 32;
    case {'win64', 'win32'} % on Windows, Resolution: 1366x768
    LabelFontSize = 26;
    case 'glnxa64' % on Linux, Resolution: 1280x1024
    LabelFontSize = 32;
end
LabelFontWeight = 'Normal';

% legend font size
LegendFontSize = 26;
% legend location
LegendLoc = 'Best'; %'SouthEast'; %'NorthEast';

% axes font size
switch SYSTEM_VERSION
    case 'maci64' % on MacOSX 
    TickFontSize = 58;
    case {'win64', 'win32'} % on Windows, Resolution: 1366x768
    TickFontSize = 30; %26;
    case 'glnxa64' % on Linux, Resolution: 1280x1024
    TickFontSize = 58;
end
% axes line width
AxesLineWidth = 4;
% axes color
AxesColor = 0.01*[.3 .3 .3];

% Residue number tick and position
ResidueTickPos = floor((IndexOffset+1)/ResidueTickStep)*ResidueTickStep : ...
                 ResidueTickStep : ...
                 ceil((IndexOffset+length(Kappa)+1)/ResidueTickStep)*ResidueTickStep; % tick's position
for i = 1:length(ResidueTickPos)
    ResidueTick{i} = ['$' num2str(ResidueTickPos(i)) '$'];
end
switch 2
    case 0
        ResidueTickInd = 1:length(ResidueTickPos);
    case 1
        ResidueTickInd = 1:(length(ResidueTickPos)-1);
    case 2
        ResidueTickInd = 2:(length(ResidueTickPos)-1);
end

% Angle tick and position
AngleTick = {'$-\pi$','$-\displaystyle\frac{\pi}{2}$','$0$','$\displaystyle\frac{\pi}{2}$','$\pi$'};
AngleTickPos = -pi:pi/2:pi;


%% plot figure
set(myfigure, 'Position', FigurePosition, 'color','w', 'InvertHardCopy','off');
set(myfigure, 'NumberTitle', 'off', 'ToolBar', 'none');
set(myfigure, 'Name', FigureName, 'FileName', FigureName);

% indice of residue
ResidueIndex = (1:length(Kappa)) + IndexOffset;

% kappa curve
kappaHandle = plot(ResidueIndex, Kappa);

hold on

% tau curve
tauHandle = plot(ResidueIndex, Tau);

% setting kappa curve
set(kappaHandle       , ...
    'LineStyle'       , LineType{1},...
    'LineWidth'       , LineWidth(1), ...
    'Color'           , kappaColor,...
    'Marker'          , MarkerType(1), ...
    'MarkerFaceColor' , kappaColorF,...
    'MarkerSize'      , MarkerSize);

% setting tau curve
set(tauHandle              , ...
    'LineStyle'       , LineType{2},...
    'LineWidth'       , LineWidth(2), ...
    'Color'           , tauColor,...
    'Marker'          , MarkerType(2), ...
    'MarkerFaceColor' , tauColorF,...
    'MarkerSize'      , MarkerSize);

% set axis
set(gca           , ... 
    'FontName'    , 'Helvetica'             , ...
    'XLim'        , XLim                    , ...
    'YLim'        , [-1*pi 1*pi]            , ...
    'Box'         , 'on'                    , ...
    'TickDir'     , 'in'                    , ...
    'TickLength'  , [.02 .02]               , ...
    'XMinorTick'  , XMinorTick              , ...
    'YMinorTick'  , 'off'                   , ...
    'XTickMode'   , 'auto'                  , ...
    'XGrid'       , 'off'                   , ...
    'YGrid'       , 'off'                   , ...
    'XColor'      , AxesColor               , ... %[0 0 0] %[.3 .3 .3]
    'YColor'      , AxesColor               , ... %[0 0 0] %[.3 .3 .3]
    'XTick'       , []                      , ...
    'XTickLabel'  , []                      , ...
    'YTick'       , -pi:pi/2:pi             , ...
    'YTickLabel'  , []                      , ...
    'LineWidth'   , AxesLineWidth);

% set ticks and labels
switch 1
    case 1
        %------------------------------------------------------------------
        % use text to set ticks
        % x ticks
        for i = 1:length(ResidueTickPos)
            ResidueTick{i} = num2str(ResidueTickPos(i));
        end
        set(gca, 'XTick', ResidueTickPos(ResidueTickInd), 'XTickLabel', ResidueTick(ResidueTickInd));
        set(gca, 'FontSize', TickFontSize, 'FontWeight', 'Bold');
        % y ticks
        AngleTick = {'-\pi','-\pi/2','0','\pi/2','\pi'};
        set(gca, 'YTick', AngleTickPos, 'YTickLabel', []);
        YTickRatio = 0.2; %0.05;
        YTickX = repmat(XLim(1)-YTickRatio, length(AngleTickPos), 1);
        %YTickX = repmat(XLim(1)-YTickRatio*(ResidueTickPos(2)-ResidueTickPos(1)), length(AngleTickPos), 1);
        hYTickText = text(YTickX, AngleTickPos, AngleTick);
        set(hYTickText, 'FontSize', TickFontSize+2, 'FontWeight', 'Bold');
        set(hYTickText, 'HorizontalAlignment', 'Right');
        
        % set labels
        if ~PubSwitch
            % x label
            hXLabel = xlabel('RESIDUE'); % ''; for empty line
            set(hXLabel, 'FontSize', LabelFontSize, 'FontWeight', LabelFontWeight);
            
            % y label
            hYLabel = ylabel({'RADIANS', '', ''}); % ''; for empty line
            set(hYLabel, 'FontSize', LabelFontSize, 'FontWeight', LabelFontWeight);
        end
        %------------------------------------------------------------------
    case 2
        %------------------------------------------------------------------
        TickOffset = 0.031; %[]; % offset of ticks
        % use format_ticks to set ticks
        format_ticks(gca, ...
                     ResidueTick(ResidueTickInd), ...
                     AngleTick, ...
                     ResidueTickPos(ResidueTickInd), ...
                     AngleTickPos, 0, 0, TickOffset, ...
                     'FontSize', TickFontSize, 'FontWeight', 'Bold');
        
        if ~PubSwitch
            % x label
            % default : {' ';'Amino acid (PDB index)'}
            switch 0
                case 0
                    hXLabel = xlabel({' ';'RESIDUE'});
                case 1
                    hXLabel = xlabel({' ';'Site'});
            end
            set(hXLabel, 'FontSize', LabelFontSize, 'FontWeight', LabelFontWeight);
            %set(hXLabel, 'Color', 'k', 'Position', [(ResidueTickPos(1)+ResidueTickPos(end))/2 -3.3 1]);
            
            % y label
            hYLabel = ylabel({'RADIANS'; ''; ''});
            set(hYLabel, 'FontSize', LabelFontSize, 'FontWeight', LabelFontWeight);
            %set(hYLabel, 'Color', 'k', 'Position', [IndexOffset-3.3 0 1]);
        end
        %------------------------------------------------------------------
end

if ~PubSwitch
    % legends
    if isempty(LegendString)
        switch 3
            case 1 % default legend string
                LegendString = {'Curvature','Torsion'};
            case 2 % latex legend string
                LegendString = {'\kappa','\tau'};
            case 3 % for angle differences
                LegendString = {'\Delta\kappa','\Delta\tau'};
        end
    end
    % legend
    hLegend = legend(LegendString);
    % set legend
    set(hLegend, 'Location', LegendLoc, 'FontSize', LegendFontSize+8, 'FontWeight', 'Normal');
    % enlarge legend frame to fit content
    set(hLegend, 'Position', get(hLegend, 'Position')+[-0.02 0 0.02 0]);
    % child objects of legend
    hLegChild = get(hLegend, 'Children');
    % remove line marker in legend
    set(hLegChild(1), 'Marker', 'none');
    % lengthen line in legend
    XData = get(hLegChild(2), 'XData');
    XDataShift = [0 (XData(2)-XData(1))*(0.1)];
    set(hLegChild(2), 'XData', XData+XDataShift);
    set(hLegChild(3), 'Position', get(hLegChild(3), 'Position')+[XDataShift(2)*1.5 0.05 0]);
    % remove line marker in legend
    set(hLegChild(4), 'Marker', 'none');
    % lengthen line in legend
    XData = get(hLegChild(5), 'XData');
    XDataShift = [0 (XData(2)-XData(1))*(0.1)];
    set(hLegChild(5), 'XData', XData+XDataShift);
    set(hLegChild(6), 'Position', get(hLegChild(6), 'Position')+[XDataShift(2)*1.5 0.05 0]);
end


end

