function PlotAngles(ExptAngles, SimuAngles, IndexOffset, XLim, ResidueTickStep, XMinorTick, PubSwitch)
%% PLOTANGLES
% Description: plot experiment and simulation angles-{kappa, tau}, kappa for curvature and tau for torsion.
% Author: Jin Dai
% Created Date: 2014.05.09
% Latest Modified Date: 2015.01.19


%% default settings
if nargin < 7
    % publish switch to close legend and axis labels
    PubSwitch = 1;
end

if nargin < 6
    XMinorTick = 'on';
end

if nargin < 5 || isempty(ResidueTickStep)
    ResidueTickStep = 5; % Step length between each tick
end

if nargin < 4 || isempty(XLim)
    % axes X-Limit
    XLim = [IndexOffset IndexOffset+length(ExptAngles)+2];
end

% check operating system version
SYSTEM_VERSION = computer('arch');


%% figure parameters settings
% line and marker color
% experiment
exptcolr = 0.3*[1 1 1; 1 1 1]; 
%[1 0 0];%'r'; % [1 0 1]; %[0. 0.6 0]; 
exptcolrF = exptcolr;
% simulation
simucolr = [1 0 0; 0 0 1];
%'b'; % [0 1 1]; %[0.2 0.8 0.8]; 
simucolrF = simucolr;

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

% line width
LineWidth = [6 6];%[5 5]; %[expt simu]
% line type
LineType = [{'-'}, {'--'}]; %[expt simu]

% marker size
MarkerSize = 12;%9;
% marker type
MarkerType = ['*', 'o']; %[expt simu]

% x-label and y-label font size
switch SYSTEM_VERSION
    case 'maci64' % on MacOSX 
    LabelFontSize = 32;
    case {'win64', 'win32'} % on Windows, Resolution: 1366x768
    LabelFontSize = 26;
    case 'glnxa64' % on Linux, Resolution: 1280x1024
    LabelFontSize = 32;
end
% label font weight
LabelFontWeight = 'Normal';

% legend font size
LegendFontSize = 16; % default: 26 % 16 for 2BEG
% legend location
LegendLoc = 'NorthEast';

% axes font size
switch SYSTEM_VERSION
    case 'maci64' % on MacOSX 
    TickFontSize = 58;
    case {'win64', 'win32'} % on Windows, Resolution: 1366x768
    TickFontSize = 30;
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
                 ceil((IndexOffset+length(ExptAngles)+1)/ResidueTickStep)*ResidueTickStep; % tick's position
for i = 1:length(ResidueTickPos)
    ResidueTick{i} = ['$' num2str(ResidueTickPos(i)) '$'];
end
ResidueTickInd = 2:(length(ResidueTickPos)-1);

% Angle tick and position
AngleTick = {'$-\pi$','$-\displaystyle\frac{\pi}{2}$','$0$','$\displaystyle\frac{\pi}{2}$','$\pi$'};
AngleTickPos = -pi:pi/2:pi;


%%
for PlotDataType = 1:2 % 1 for kappa % 2 for tau
    myfigure=figure;
    switch PlotDataType
        case 1
            AngleName = 'RADIANS'; %'Bond angle (radians)'; %'Kappa';
            FileName = 'Bond angle';
            TextString = 'a)';
        case 2
            AngleName = 'RADIANS'; %'Torsion angle (radians)'; %'Tau';
            FileName = 'Torsion angle';
            TextString = 'b)';
        otherwise
            AngleName = 'Angles';
            FileName = 'angles';
            TextString = [];
    end
    set(myfigure, 'Position', FigurePosition, 'color','w', 'InvertHardCopy','off');
    set(myfigure, 'NumberTitle', 'off', 'ToolBar', 'none');
    set(myfigure, 'Name', ['Residue Number v.s. ' FileName]);
    set(myfigure, 'FileName', ['Residue Number v.s. ' FileName]);
    set(myfigure, 'Renderer', 'painters');
        
    % indice of residue
    ResidueIndex = (1:length(ExptAngles)) + IndexOffset;
    
    % experiment kappa
    expt = plot(ResidueIndex, ExptAngles(:,PlotDataType));

    hold on
    
    % simulation kappa
    simu = plot(ResidueIndex, SimuAngles(:,PlotDataType));

    % set line for expt
    set(expt              , ...
        'LineStyle'       , LineType{1},...
        'LineWidth'       , LineWidth(1), ...
        'Color'           , exptcolr(PlotDataType,:),...
        'Marker'          , MarkerType(1), ...    
        'MarkerFaceColor' , exptcolrF(PlotDataType,:),...
        'MarkerSize'      , MarkerSize);

    % set line for simu
    set(simu              , ...
        'LineStyle'       , LineType{2},...
        'LineWidth'       , LineWidth(2), ...
        'Color'           , simucolr(PlotDataType,:),... 
        'Marker'          , MarkerType(2), ...     
        'MarkerFaceColor' , simucolrF(PlotDataType,:),...
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
        'XGrid'       , 'off'                   , ...
        'YGrid'       , 'off'                   , ...
        'XColor'      , AxesColor               , ... %[0 0 0] %[.3 .3 .3]
        'YColor'      , AxesColor               , ... %[0 0 0] %[.3 .3 .3]
        'XTick'       , []                      , ...
        'XTickLabel'  , []                      , ...
        'XTickMode'   , 'auto'                  , ...
        'YTick'       , -pi:pi/2:pi             , ...
        'YTickLabel'  , []                      , ...
        'LineWidth'   , AxesLineWidth);
    
    % set ticks and labels
    switch 1
        case 1 
            %--------------------------------------------------------------
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
                hYLabel = ylabel({AngleName, '', ''}); % ''; for empty line
                set(hYLabel, 'FontSize', LabelFontSize, 'FontWeight', LabelFontWeight);
                
                % figure text string
                if ~isempty(TextString) && 0
                    hText = text(XLim(1)+0.35, pi-0.55, TextString);
                    set(hText, 'FontSize', 34, 'FontWeight', 'bold');
                end
            end
            %--------------------------------------------------------------
        case 2
            %--------------------------------------------------------------
            % use format_ticks to set ticks
            format_ticks(gca,...
                         ResidueTick(ResidueTickInd),...
                         AngleTick,...
                         ResidueTickPos(ResidueTickInd),...
                         AngleTickPos,0,0,[],...
                         'FontSize',TickFontSize,'FontWeight','Bold');
            % set labels
            if ~PubSwitch
                % x label
                % default : {' ';'Amino acid (PDB index)'}
                switch 0
                    case 0
                        hXLabel = xlabel({''; 'RESIDUE'}); % ''; for empty line
                    case 1
                        hXLabel = xlabel({'Site'}); % ''; for empty line
                end
                set(hXLabel, 'FontSize', LabelFontSize, 'FontWeight', LabelFontWeight);
                %set(hXLabel, 'Position', [(ResidueTickPos(1)+ResidueTickPos(end))/2 -3.2 1]);
                
                % y label
                hYLabel = ylabel({AngleName; ''; ''}); % ''; for empty line
                set(hYLabel, 'FontSize', LabelFontSize, 'FontWeight', LabelFontWeight);
                %set(hYLabel, 'Position', [IndexOffset-2.5 0 1]);
                
                % figure text string
                if ~isempty(TextString) && 1
                    hText = text(XLim(1)+0.55, pi-0.55, TextString);
                    set(hText, 'FontSize', 30, 'FontWeight', 'bold');
                end
            end
            %--------------------------------------------------------------
    end
    
    if ~PubSwitch
        % legends
        switch 3
            case 1 % default legend string
                hLegend = legend('Experiment','Simulation');
            case 2 % legend string used in 1AIK paper
                hLegend = legend('All-atom','DNLS');
            case 3 % legend string used in 3DXC paper
                hLegend = legend('PDB','SOLITON');
            case 4 % legend string used in FindStructuresPathwayEn.m
                hLegend = legend('Initial','Average');
        end
        set(hLegend, 'location', LegendLoc, 'FontSize', LegendFontSize, 'FontWeight', 'Normal');
        % enlarge legend frame to fit content
        set(hLegend, 'Position', get(hLegend, 'Position')+[-0.06 0 0.06 0]);
        % child objects of legend
        hLegChild = get(hLegend, 'Children');
        % remove line marker in legend 
        set(hLegChild(1), 'Marker', 'none');
        % lengthen line in legend
        XData = get(hLegChild(2), 'XData');
        XDataShift = [0 (XData(2)-XData(1))*(0.6)];
        set(hLegChild(2), 'XData', XData+XDataShift);
        set(hLegChild(3), 'Position', get(hLegChild(3), 'Position')+[XDataShift(2)*1.2 0 0]);
        % remove line marker in legend
        set(hLegChild(4), 'Marker', 'none');
        % lengthen line in legend
        XData = get(hLegChild(5), 'XData');
        XDataShift = [0 (XData(2)-XData(1))*(0.6)];
        set(hLegChild(5), 'XData', XData+XDataShift);
        set(hLegChild(6), 'Position', get(hLegChild(6), 'Position')+[XDataShift(2)*1.2 0 0]);
    end
    
    % output figure with function export_fig
    if false
        export_fig(['Residue Number v.s. ' FileName '.jpg'], '-painters', '-r600', '-nocrop');
    end
end


end
