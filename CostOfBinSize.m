function Cost = CostOfBinSize(Data, GridNum, PlotSwitch)
%% COSTOFBINSIZE
% Description: calculate the cost of bin-size using Shimazaki and Shinomoto, Neural Comput 19 1503-1527, 2007
% Author: Jin Dai
% Created Date: 2017.06.07
% Last Modified Date: 2017.06.07


%% default arguments
if nargin < 3
    PlotSwitch = false;
end

if nargin < 2 || isempty(GridNum)
    GridNum = 2:50;
end

if size(Data,1) == 1
    Data = Data';
end


%% calculate cost as the function of bin size
Cost = nan(numel(GridNum), size(Data,2));
LegendStr = cell(1,size(Data,2));

for iCol = 1:size(Data,2)
    GridLim = [min(Data(:,iCol))-eps, max(Data(:,iCol))+eps];
    
    for iG = 1:numel(GridNum)
        GridCtr = linspace(GridLim(1), GridLim(end), GridNum(iG));
        
        K = hist(Data(:,iCol), GridCtr);
        KMean = mean(K);
        KVar = var(K, 1);
        
        Cost(iG, iCol) = (2*KMean-KVar)/((GridCtr(2)-GridCtr(1))^2);
    end
    
    LegendStr{iCol} = sprintf('Col %d', iCol);
end

%% plot cost function
if PlotSwitch
    CreateFigure('Cost as function of bin size');
    
    plot(GridNum, Cost, 'o--', 'LineWidth', 3);
    
    set(gca, 'XLim', [GridNum(1) GridNum(end)]);
    set(gca, 'LineWidth', 2, 'FontSize', 12);
    set(gca, 'Box', 'off');
    
    xlabel('Number of Bins', 'FontSize', 24);
    ylabel('Cost', 'FontSize', 24);
    
    legend(LegendStr, 'FontSize', 12, 'Location', 'EastOutside');
end


end

