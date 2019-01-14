function FigurePosition = CreateFigurePosition(SYSTEM_VERSION)
%% CREATEFIGUREPOSITION
% Description: return FigurePostion depending on different platform.
% Author: Jin Dai
% Created Date: 2015.01.19
% Latest Modified Date: 2015.01.19

%% previous default settings
% switch SYSTEM_VERSION
%     case 'maci64' % on MacOSX
%         FigurePosition = [50, 50, 1600, 900]; %[50,100,1200,800]; %[100,100,1200,800];
%     case {'win64', 'win32'} % on Windows, Resolution: 1366x768
%         FigurePosition = [30, 30, 1250, 650];
%     case 'glnxa64' % on Linux, Resolution: 1280x1024
%         FigurePosition = [200, 300, 1200, 800];
% end


%% FigurePosition
switch SYSTEM_VERSION
    case 'maci64' % on MacOSX
        FigurePosition = [40 25 1600 1000]; % for 21" MacPro, 1680x1050
        %FigurePosition = [50,100,1200,800]; % for 15" MBP
    case {'win64', 'win32'} % on Windows, Resolution: 1366x768
        FigurePosition = [30, 50, 1300, 650];
    case 'glnxa64' % on Linux, Resolution: 1280x1024
        FigurePosition = [200, 300, 1200, 800];
    otherwise % get the screen size
        FigurePosition = get(0, 'ScreenSize');
end


end

