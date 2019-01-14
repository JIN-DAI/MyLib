function [Data, hfigure] = PlotFluctuation(DataFileName, MCStep, FigureName, TickRatio)
%% PlotFluctuation.m
% Description:
% Author: Jin Dai
% Created Date: 2014.08.19
% Last Modified Date: 2016.03.10


%% Environment Settings
SYSTEM_VERSION = computer('arch');
if ~strcmp(SYSTEM_VERSION, 'maci64')
    opengl software;
end


%% Default argument

% default x-tick and y-tick ratio
if nargin < 4 || isempty(TickRatio)
    % X-Tick's ratio = MCStep.Interval*XTickRatio
    XTickRatio = 10;
    % Y-Tick's ratio
    YTickRatio = 2;
else
    XTickRatio = TickRatio(1);
    YTickRatio = TickRatio(2);
end

% default figure name
if nargin < 3 || isempty(FigureName)
    FigureName = ['Fluctuation_' datestr(now)];
end

% default Monte Carlo simulation step
if nargin < 2 || isempty(MCStep)
    % Monte Carlo Simulation Step
    MCStep.Start = 0;
    MCStep.End = 5e7;
    MCStep.Interval = 5e5;
end


%% Read data from file specified by DataFileName
% separator of average and variance
Separator = '+-';

% open file specified by DataFileName
FID = fopen(DataFileName, 'r');
if FID == -1
    fprintf('Unable to open file: ''%s''\n', DataFileName);
    Data = [];
    hfigure = [];
    return;
end

% define max line in source data file
MAX_LINE_DEF = 3000; % NOTE: this may be changed in future!
Data = zeros(MAX_LINE_DEF,2);
lineCounter = 0;

% read file by line
tline = fgetl(FID);
while ischar(tline)
    % find the first index of separator
    SeparatorIndex = strfind(tline, Separator);
    if ~isempty(SeparatorIndex)
        lineCounter = lineCounter + 1;
        % average
        Data(lineCounter, 1) = str2double(tline(1:SeparatorIndex-1));
        % variance
        Data(lineCounter, 2) = str2double(tline(SeparatorIndex+length(Separator)+1:end));
    end
    % read next line
    tline = fgetl(FID);
end
Data = Data(1:lineCounter,:);

% close data file
fclose(FID);


%% Data for plotting
% averge
Average = Data(1:end, 1);
% variance
Variance = Data(1:end, 2);
% lower line
LineLower = Average - Variance;
% upper line
LineUpper = Average + Variance;
% Monte Carlo step
x = MCStep.Start : MCStep.Interval : MCStep.End;

X = [x, fliplr(x)];

Y = [LineLower', fliplr(LineUpper')];



%% Parameter for plotting
% --- figure ---
% figure position
FigurePosition = CreateFigurePosition(SYSTEM_VERSION);
% switch SYSTEM_VERSION
%     case 'maci64' % on MacOSX 
%     FigurePosition = [40 25 1600 1000]; % for 21" MacPro, 1680x1050 
%     %FigurePosition = [50,100,1200,800]; % for 15" MBP
%     case {'win64', 'win32'} % on Windows, Resolution: 1366x768
%     FigurePosition = [30, 50, 1300, 650];
%     case 'glnxa64' % on Linux, Resolution: 1280x1024
%     FigurePosition = [200, 300, 1200, 800];
% end
% figure background color
FigureColor = 'w';


% --- axis ---
% axes color
AxesLineColor = 0.01*[.3 .3 .3];
% axes line width
AxesLineWidth = 4;
% tick font size
TickFontSize = 30;
% tick font weight
TickFontWeight = 'Bold';
% tick length
TickLength = [.02 .02];


% X-Lim & X-Tick
XLim = [MCStep.Start MCStep.End];
XExpNum = floor(log(XTickRatio*MCStep.Interval)/log(10)); % common exponential index for x-tick
XTickPos = XLim(1) : XTickRatio*MCStep.Interval : XLim(2); % x-tick's position
XTick = cell(1,length(XTickPos));
for i = 1:length(XTickPos)
    XTick{i} = ['$' num2str(XTickPos(i)/(10^XExpNum)) '$']; % x-tick's string
end


% Y-Lim & Y-Tick
YLim = [0 ceil(max(LineUpper))+10^(floor(log(max(LineUpper))/log(10)))/2];
YTickPos = YLim(1) : YTickRatio : YLim(2); % y-tick's position
YTick = cell(1,length(YTickPos));
for i = 1:length(YTickPos)
    YTick{i} = ['$' num2str(YTickPos(i)) '$']; % y-tick's string
end


% --- average line ---
AverageLineColor = 'r';
AverageLineWidth = 5;


% --- fluctuation region ---
RegionColor = 0.85*[1 1 1]; %[1 0.69 0.39]
RegionAlpha = 0.5;


% --- region edge line ---
RegionEdgeColor = 'k';
RegionEdgeWidth = 5;


%% Plot fluctuation
% figure
hfigure = figure;
set(hfigure, 'NumberTitle', 'off', 'InvertHardCopy', 'off', 'ToolBar', 'none');
set(hfigure, 'Position', FigurePosition, 'Color', FigureColor);
set(hfigure, 'Name', FigureName, 'FileName', FigureName);

% axis
haxes = axes;
set(haxes, 'NextPlot', 'add', 'FontName', 'Helvetica');
set(haxes, 'Box', 'on', 'XGrid', 'off', 'YGrid', 'off');
set(haxes, 'XColor', AxesLineColor, 'YColor', AxesLineColor, 'LineWidth', AxesLineWidth);
set(haxes, 'TickDir', 'in', 'TickLength', TickLength);
set(haxes, 'XTickMode', 'auto', 'XMinorTick', 'on', 'YMinorTick', 'on');

% fluctuation region
hpRegion = fill(X,Y,RegionColor); 
set(hpRegion, 'EdgeColor', RegionEdgeColor);
set(hpRegion, 'LineWidth', RegionEdgeWidth); 
if ~strcmp(SYSTEM_VERSION, 'maci64')
    set(hpRegion, 'FaceAlpha', RegionAlpha);
end

% average line
hpAverage = plot(x, Average);
set(hpAverage, 'Color', AverageLineColor);
set(hpAverage, 'LineWidth', AverageLineWidth);

%% Axes Tick Label
switch 1
    case 1
        %------------------------------------------------------------------
        % use text to set ticks
        % x ticks
        XTick = cell(1,length(XTickPos));
        for i = 1:length(XTickPos)
            XTick{i} = num2str(XTickPos(i)/(10^XExpNum)); % x-tick's string
        end
        set(gca, 'XLim', XLim);
        set(gca, 'XTick', XTickPos, 'XTickLabel', XTick);
        set(gca, 'FontSize', TickFontSize, 'FontWeight', TickFontWeight);
        
        % plot scale/unit text
        TextPos = [XLim(2)+0.275*mean(diff(XTickPos)), YLim(1)-0.036*(YLim(end)-YLim(1))];
        TextString1 = ['\times10^' num2str(XExpNum) ''];
        
        hText = text(TextPos(1), TextPos(2), TextString1);
        set(hText, 'FontName', 'Helvetica', 'FontSize', TickFontSize, 'FontWeight', 'Bold');
        % y ticks
        YTick = cell(1,length(YTickPos));
        for i = 1:length(YTickPos)
            YTick{i} = num2str(YTickPos(i)); % y-tick's string
        end
        set(gca, 'YLim', YLim);
        set(gca, 'YTick', YTickPos, 'YTickLabel', YTick);
        set(gca, 'FontSize', TickFontSize, 'FontWeight', TickFontWeight);
        %------------------------------------------------------------------
    case 2
        %------------------------------------------------------------------
        % use format_ticks to set ticks
        [hx, ~] = format_ticks(haxes, XTick, YTick, XTickPos, YTickPos, 0, 0, [], 'FontSize', TickFontSize, 'FontWeight', TickFontWeight);
        XTickPosMtr = cell2mat(get(hx, 'Position'));
        
        % plot scale/unit text
        TextPos = [XTickPosMtr(end,1)+0.275*mean(diff(XTickPosMtr(:,1))), 2*mean(XTickPosMtr(:,2))];
        
        TextString1 = ['$\times10^' num2str(XExpNum) '$'];
        
        hText = text(TextPos(1), TextPos(2), TextString1);
        set(hText, 'Interpreter', 'latex');
        set(hText, 'FontName', 'Helvetica', 'FontSize', TickFontSize, 'FontWeight', 'bold');
        %------------------------------------------------------------------
end



end





