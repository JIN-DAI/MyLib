function [Beta, hfigure] = PlotTemperature(xmlFileName, MCStep, TickRatio, OFFSET, FigureSwitch)
%% PlotTemperature.m
% Description: plot the change of temperature according to the xml file and the Monte Carlo simulation step settings
% Input: 
%  -xmlFileName: xml file's name;
%  -MCStep: Monte Carlo simulation step settings, with field: Start, End, Interval;
%  -TickRatio: [XTickRatio YTickRatio], 
%               X-Tick's ratio = MCStep.Interval*XTickRatio, 
%               Y-Tick's ratio = 10^YTickRatio,
%               if TickRatio == [], use default value of TickRatio;
%  -OFFSET: Tick's offset: [x-tick's y-poistion, y-tick's x-position];
%  -TextRatio: Ratio for text's position, [x-position's ratio, y-position's ratio]; (==deleted!==)
%  -FigureSwitch: display figure(true) or not(false)
% Output:
%  -Beta: struct of beta from xml file;
%  -hfigure: handle of figure.
% Author: Jin Dai
% Created Date: 2014.07.24
% Last Modified Date: 2015.02.10


%% Default Settings
% Check Operating System Version
SYSTEM_VERSION = computer('arch');
% File Separator in corresponding OS
FS = filesep;

% default FigureSwitch
if nargin < 5
    FigureSwitch = true;
end

% default Monte Carlo simulation step
if nargin < 2 || isempty(MCStep)
    % Monte Carlo Simulation Step
    MCStep.Start = 0;
    MCStep.End = 5e7;
    MCStep.Interval = 5e5;
end

%% Read temperature information from xml file
% check the existence of xml file
if exist(xmlFileName, 'file') ~= 2
    fprintf('ERROR: %s does not exist!\n', xmlFileName);
    Beta = [];
    hfigure = [];
    return;
end

% read xml file into corresponding parameter struct
parameterStruct = ReadParameters(xmlFileName);

% read beta information-{Struct, Node, Type}
Beta.Struct = parameterStruct.Globals.beta; % beta struct from parameterStruct
Beta.Node = [MCStep.Start Beta.Struct.Start]; % node to store the key points of beta
% change type of beta between nodes-{'Flat', 'Linear', 'Exponential'}
Beta.Type = {'Flat'};
if isfield(Beta.Struct, 'Changes')   
    for i = 1:length(Beta.Struct.Changes)
        Beta.Node = [Beta.Node; Beta.Struct.Changes(i).Value];
        Beta.Type = [Beta.Type [Beta.Struct.Changes(i).Type {'Flat'}]];
    end
    Beta.Node = [Beta.Node; MCStep.End Beta.Node(end, 2)];
else
    Beta.Node = [Beta.Node; MCStep.End Beta.Struct.Start];
end

% change Beta into TemperatureArray = [MCStepArray; Temperature]
TempArray = []; % Array to store the beta value and corresponding MC recording step
for iNode = 1:length(Beta.Node)-1
    % MC-step from i-th Beta.Node to (i+1)-th Beta.Node
    TempStep = Beta.Node(iNode,1) : MCStep.Interval : Beta.Node(iNode+1,1);
    TempStep = TempStep(1:end-1); % Beta.Node(i+1,1) is belong to the next segment
    
    % beta from i-th Beta.Node to (i+1)-th Beta.Node
    switch Beta.Type{iNode}
        case 'Flat' % beta keeps in constant
            TempBeta = Beta.Node(iNode,2) * ones(1, length(TempStep));
        case 'Linear' % beta changes linearly
            TempBeta = Linear(TempStep-Beta.Node(iNode,1), Beta.Node(iNode,2), Beta.Node(iNode+1,2), Beta.Node(iNode+1,1)-Beta.Node(iNode,1));
        case 'Exponential' % beta changes exponentially
            TempBeta = Exponential(TempStep-Beta.Node(iNode,1), Beta.Node(iNode,2), Beta.Node(iNode+1,2), Beta.Node(iNode+1,1)-Beta.Node(iNode,1));
    end
    
    % store MC-step and beta
    TempArray = [TempArray; [TempStep' TempBeta']];
end
TempArray = [TempArray; Beta.Node(end,1) Beta.Node(end,2)]; % store the last node

Beta.Array = TempArray; % store (MC-step,beta)-array into Beta.Array
Temperature.Array = [TempArray(:,1) 1./TempArray(:,2)]; % temperature = 1/beta

%% ========================================================================
if FigureSwitch
    %% Plot Settings
    % parameters for different xml files
    % --------------
    %(==deleted!==)
    % if nargin < 5
    %     % Ratio for text's position: [x-position's ratio, y-position's ratio]
    %     TextRatio = [3, -1.45];
    % end
    
    % if nargin < 4
    %     % Tick's offset: [x-tick's y-poistion, y-tick's x-position]
    %     OFFSET = [2.75e-9 0.095];
    % end
    
    if nargin < 3 || isempty(TickRatio)
        % X-Tick's ratio = MCStep.Interval*XTickRatio
        XTickRatio = 10;
        % Y-Tick's ratio = 10^YTickRatio
        YTickRatio = 2;
    else
        XTickRatio = TickRatio(1);
        YTickRatio = TickRatio(2);
    end
    
    % --------------
    
    
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
    % figure name
    IndexFS = strfind(xmlFileName, FS); % index of file seperator in xml file name
    IndexEXT = strfind(xmlFileName, '.xml'); % index of file extension in xml file name
    if isempty(IndexFS)
        FigureName = ['Temperature_' xmlFileName(1:IndexEXT-1)];
    else
        FigureName = ['Temperature_' xmlFileName(IndexFS(end)+1:IndexEXT-1)];
    end
    
    
    % --- axis ---
    % axes color
    AxesLineColor = 0.01*[.3 .3 .3];
    % axes line width
    AxesLineWidth = 4;
    % tick font size
    TickFontSize = 30;
    % tick length
    TickLength = [.02 .02];
    
    % Y-tick hortizontal alignment
    YHorizontalAlignment = 'left';
    
    % X-Lim & X-Tick
    XLim = [MCStep.Start MCStep.End];
    XExpNum = floor(log(XTickRatio*MCStep.Interval)/log(10)); % common exponential index for x-tick
    XTickPos = XLim(1) : XTickRatio*MCStep.Interval : XLim(2); % x-tick's position
    XTick = cell(1,length(XTickPos));
    for i = 1:length(XTickPos)
        XTick{i} = ['$' num2str(XTickPos(i)/(10^XExpNum)) '$']; % x-tick's string
    end
    
    % Y-Lim & Y-Tick
    YLim = [min(Temperature.Array(:,2)) max(Temperature.Array(:,2))];
    YExpNum = round(log(YLim(1))/log(10)) : YTickRatio : round(log(YLim(2))/log(10));
    YTickPos = 10.^YExpNum; % y-tick's position
    YTick = cell(1,length(YTickPos));
    for i = 1:length(YTickPos)
        YTick{i} = ['$' '10^{' num2str(YExpNum(i)) '}' '$']; % y-tick's string
    end
    
    if nargin < 4 || isempty(OFFSET)
        % Tick's offset: [x-tick's y-poistion, y-tick's x-position]
        OFFSET(1) = 0.5;
        OFFSET(2) = 0.095;
    end
    
    % --- line ---
    LineColor = 'r';%'b';
    LineWidth = 7;
        
    %% Plotting
    hfigure = figure;
    set(hfigure, 'NumberTitle', 'off', 'InvertHardCopy', 'off', 'ToolBar', 'none');
    set(hfigure, 'Position', FigurePosition, 'Color', FigureColor);
    set(hfigure, 'Name', FigureName, 'FileName', FigureName);
    
    % axis
    haxes = axes;
    
    % plot curve
    hp = semilogy(haxes, Temperature.Array(:,1), Temperature.Array(:,2));
    set(hp, 'LineWidth', LineWidth, 'Color', LineColor);
    
    %set(haxes, 'NextPlot', 'add', 'FontName', 'Helvetica');
    set(haxes, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'off');
    set(haxes, 'XColor', AxesLineColor, 'YColor', AxesLineColor, 'LineWidth', AxesLineWidth);
    set(haxes, 'TickDir', 'in', 'TickLength', TickLength);
    set(haxes, 'XMinorTick', 'on', 'YMinorTick', 'on');
    [hx, hy] = format_ticksLog(haxes, XTick, YTick, XTickPos, YTickPos, 0, 20, OFFSET, 'FontSize', TickFontSize, 'FontWeight', 'Bold');
    set(hy, 'HorizontalAlignment', YHorizontalAlignment);
    
    XTickPosMtr = cell2mat(get(hx, 'Position'));
    
    %xlabel('step', 'FontSize', 32, 'FontWeight', 'bold');
    %ylabel('temperature', 'FontSize', 32, 'FontWeight', 'bold');
    
    %TextPos = [XLim(end)+TextRatio(1)*MCStep.Interval YLim(1)+TextRatio(2)*OFFSET(1)*(YLim(2)-YLim(1)) 0]; (==deleted!==)
    TextPos = [XTickPosMtr(end,1)+0.275*mean(diff(XTickPosMtr(:,1))), OFFSET(1)*mean(XTickPosMtr(:,2))];
    
    TextString1 = ['$\times10^' num2str(XExpNum) '$'];
    
    hText = text(TextPos(1), TextPos(2), TextString1);
    set(hText, 'Interpreter', 'latex');
    set(hText, 'FontName', 'Helvetica', 'FontSize', TickFontSize, 'FontWeight', 'bold');
       
end
%% ========================================================================


end

