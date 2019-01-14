function PCABasicPlots(PCA, FigureNamePrefix, Control)
%% PCABASICPLOTS
% Description: plot basic figures for PCA structure which is usually created by PCAOnFrames(...)
%              Following Figures are plotted:
%              1. Percentage of sum of first k-th eigenvalues
%              2. Free energy landscape of 2D PC planes
%              3. Frequency distribution along first k-th PCs
%              4. AutoCorrelation in function of lag time or frame
%              5. Detail components in PC 
% Author: J.Dai
% Created Date: 2017.06.24
% Last Modified Date: 2017.06.24


%%
% control of plotting
if nargin < 3
    Control = 1:5;
end

% prefix of figure name
if nargin < 2 || isempty(FigureNamePrefix)
    FigureNamePrefix = '';
end


%% 1.Percentage of sum of first k-th eigenvalues
if any(Control == 1)
    LatentPercentage = nan(1, length(PCA.latent)+1);
    LatentPercentage(1) = 0;
    for i = 2:length(PCA.latent)+1
        LatentPercentage(i) = 100*sum(PCA.latent(1:i-1))/sum(PCA.latent);
    end
    
    CreateFigure([FigureNamePrefix 'fluctuations sum of first k-th PCs_' PCA.Type]);
    
    plot(0:length(PCA.latent), LatentPercentage, 'ro-', 'LineWidth', 2, 'MarkerFaceColor', 'r');
    hold on
    stem(1:length(PCA.latent), diff(LatentPercentage), 'b^-', 'LineWidth', 2, 'MarkerFaceColor', 'b');
    
    set(gca, 'XLim', [0, length(PCA.latent)], 'YLim', [0, 100]);
    set(gca, 'LineWidth', 2, 'FontSize', 14);
    
    xlabel('number of eigenvectors', 'FontSize', 24);
    ylabel('fluctuations [%]', 'FontSize', 24);
    
    legend({'sum of \sigma_i', '\sigma_i'}, 'FontSize', 20, 'Location', 'Best');
end


%% 2.Probability distribution along first k-th PCs
if any(Control == 2)
    PC_Range = (1:8)+8*0;
    
    if false
        CostOfBinSize(PCA.score(:,PC_Range), [], 1);
    end
    
    MaxScore = ceil(max(max(PCA.score(:,PC_Range)))*2)/2;
    MinScore = floor(min(min(PCA.score(:,PC_Range)))*2)/2;
    
    Marker = '';
    
    CreateFigure([FigureNamePrefix 'Probability distribution along PC_' PCA.Type]);

    PCSet = num2cell(PC_Range);
    for i = 1:numel(PCSet)
        PCNum = PCSet{i};
        subplot(2,numel(PC_Range)/2,i);
        [BinH,BinC] = hist(PCA.score(:,PCNum), 30);
        
        Prob = BinH./sum(BinH(:));
        
        plot(BinC, Prob, ['r-', Marker], 'LineWidth', 2, 'MarkerFaceColor', 'r');
        set(gca, 'FontSize', 12, 'FontWeight', 'Bold');
        set(gca, 'Box', 'off', 'LineWidth', 1);
        set(gca, 'XLim', [MinScore, MaxScore], 'XTick', ceil(MinScore):floor(MaxScore));
        %axis tight;
        
        xlabel(sprintf('PC%d', PCNum), 'FontSize', 12, 'FontWeight', 'Bold');
        ylabel('Probability', 'FontSize', 12, 'FontWeight', 'Bold');
    end
end


%% 3.Free energy landscape of 2D PC planes
if any(Control == 3)
    CreateFigure([FigureNamePrefix 'Free Energy Landscape on PCs plane_' PCA.Type]);
    
    MaxPCk = 12;
    PCSet = mat2cell(reshape(1:MaxPCk, 2, [])', ones(MaxPCk/2,1), 2);
    
    PlotStyle = 'contour';
    
    for i = 1:numel(PCSet)
        PCNum = PCSet{i};
        subplot(2,MaxPCk/4,i);
        
        switch PlotStyle
            case {'pcolor', 'contour'}
                % calculate bin heights
                [BinH, BinC] = hist3(PCA.score(:,PCNum), [30,30]);
                
                % calculate probability
                Prob = BinH./sum(BinH(:));
                MaxP = max(Prob(:));
                Prob(Prob==0) = eps;
                
                % calculate free energy G and scale it for visualization
                G = -(log(Prob)-log(MaxP));
                G = G.^(1/3);
                
                % plot G
                switch PlotStyle
                    case 'pcolor'
                        pcolor(BinC{1}, BinC{2}, G');
                        %shading flat;
                    case 'contour'
                        contour(BinC{1}, BinC{2}, G', 20);
                end
                
                % set color map
                colormap(hot(128));
                
                % freeze color
                freezeColors;
            case 'plot'
                plot(PCA.score(:,PCNum(1)), PCA.score(:,PCNum(2)), 'r.');
        end
        
        %set(gca, 'CLim', [min(P(:)), max(P(:))]);
        set(gca, 'FontSize', 10, 'FontWeight', 'Bold');
        set(gca, 'LineWidth', 2);
        
        xlabel(sprintf('PC%d', PCNum(1)), 'FontSize', 12, 'FontWeight', 'Bold');
        ylabel(sprintf('PC%d', PCNum(2)), 'FontSize', 12, 'FontWeight', 'Bold');
        
        hold on;
        
        % arrows for the evolution of trajectory
        PtsN = 0;
        PtsIdx = linspace(1, size(PCA.score,1), PtsN);
        PtsPos = nan(PtsN, 2);
        for iP = 1:PtsN
            PtsPos(iP,:) = [PCA.score(round(PtsIdx(iP)),PCNum(1)), PCA.score(round(PtsIdx(iP)),PCNum(2))];
            plot(PtsPos(iP,1), PtsPos(iP,2), 'o', 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
            if iP ~= 1
                arrow([PtsPos(iP-1,1), PtsPos(iP-1,2)], ...
                      [PtsPos(iP,1), PtsPos(iP,2)], ...
                      'EdgeColor', 'none', 'FaceColor', 'y', 'Width', 1);
            end
        end
    end
end


%% 4.AutoCorrelation in function of lag time or frame
if any(Control == 4)
    CreateFigure([FigureNamePrefix 'AutoCorrelation of PC_' PCA.Type]);
    
    PC_Range = 1:10;
    LagT = 0:(size(PCA.AutoCorr, 1)-1);
    LagT = repmat(LagT', 1, numel(PC_Range));
    
    set(gca, 'NextPlot', 'add');
    hLine = plot(LagT, PCA.AutoCorr(:,PC_Range), 'LineWidth', 2);
    set(hLine, {'Color'}, mat2cell(hsv(numel(PC_Range)), ones(numel(PC_Range),1)));
    
    LegendStr = strcat('PC', cellfun(@num2str, num2cell(PC_Range), 'UniformOutput', false));
    
    plot([LagT(1) LagT(end)], [0 0], 'k--', 'LineWidth', 2);
    
    set(gca, 'XLim', [0, size(PCA.AutoCorr,1)], 'YLim', [floor(min(PCA.AutoCorr(:))*10)/10,1]);
    set(gca, 'LineWidth', 2, 'FontSize', 16, 'Box', 'Off');

    xlabel('lag frame', 'FontSize', 20, 'FontWeight', 'Normal');
    ylabel('autocorrelation', 'FontSize', 20, 'FontWeight', 'Normal');
    legend(LegendStr, 'FontSize', 18, 'FontWeight', 'Normal');
end


%% 5.Detail components in PC
if any(Control == 5)
    % NOTE: divide the contribution by curvature and torsion
    CreateFigure([FigureNamePrefix 'Detail components in PC_' PCA.Type]);

    TagList = unique(PCA.Tag(2,:));
    Contrib = nan(numel(TagList), size(PCA.coeff,2));
    for iTag = 1:numel(TagList)
        Index = (PCA.Tag(2,:) == TagList(iTag));
        CoeffVec = PCA.coeff(Index,:);
        Contrib(iTag,:) = sqrt(diag(CoeffVec'*CoeffVec));
    end

    PC_Range = 1:6;
    if 1
        for i = 1:numel(PC_Range)
            PCk = PC_Range(i);
            
            subplot(numel(PC_Range),1,i);
            bar(Contrib(:,PCk), 1.0);
            
            set(gca, 'XLim', [1, size(Contrib, 1)], 'YLim', [0,1]);
            set(gca, 'LineWidth', 3, 'FontSize', 10);
            set(gca, 'Box', 'off');
            
            title(sprintf('PC%d', PCk), 'FontSize', 12, 'FontWeight', 'Bold');
        end
    else
        bar(Contrib(:,PC_Range), 'stack');
        
        %set(gca, 'XLim', [1, size(Contrib, 1)], 'YLim', [0,1]);
        set(gca, 'LineWidth', 3, 'FontSize', 10);
        set(gca, 'Box', 'off');
        
        legend(strcat('PC', cellfun(@num2str, num2cell(PC_Range), 'UniformOutput', false)), 'FontSize', 12, 'FontWeight', 'Bold');
    end
end

end

