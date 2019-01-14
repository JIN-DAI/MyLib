function FigureHandle = CreateFigure(FigureName, FigurePosition)
%% CREATEFIGURE Summary of this function goes here
%   Detailed explanation goes here

%%
if nargin < 2
    FigurePosition = [100 50 1200 650];
end
FigureHandle = figure('Position', FigurePosition);
set(gcf, 'Name', FigureName, 'FileName', FigureName);
set(gcf, 'NumberTitle', 'off', 'Color', 'w', 'ToolBar', 'none');

end

