function [BinNum, BinVec, BinCenter] = MakeHist(Data, XAxis)
%% MAKEHIST 
% Description: even bin centers
% Author: J.Dai
% Created Date: 2016.01.12
% Last Modified Date: 2016.01.12

%%
% center of bins
BinCenter = XAxis(1):XAxis(3):XAxis(2);


% vector of bins to record the bin index of each data point
BinVec = nan(length(Data), 1);
BinVec(Data < (XAxis(1)-XAxis(3)/2)) = -inf; % less than the left boundary -> -inf
BinVec(Data > (XAxis(2)+XAxis(3)/2)) = +inf; % larger than the right boundary -> +inf
BinInd = find(isnan(BinVec));

% if input Data is nan for each element
if all(isnan(Data))
    BinNum = zeros(length(BinCenter),1);
    return;
end

% only check data in the range of [(XAxis(1)-XAxis(3)/2, XAxis(2)+XAxis(3)/2]
DataTrim = Data(Data >= (XAxis(1)-XAxis(3)/2) & Data <= (XAxis(2)+XAxis(3)/2));
if any(DataTrim - Data(BinInd))
    fprintf('NOTE: the indice in the range are different!\n');
end

% get bin number with matrices
% edge of bins
BinEdge = zeros(length(BinCenter), 2);
% left endpoints of bins
BinEdge(1,1) = min(min(DataTrim),BinCenter(1))-eps; % -eps to make sure the minimal value to be included
BinEdge(2:end,1) = (BinCenter(1:end-1)+BinCenter(2:end))/2;
% right endpoints of bins
BinEdge(1:end-1,2) = (BinCenter(1:end-1)+BinCenter(2:end))/2;
BinEdge(end,2) = max(max(DataTrim),BinCenter(end))+eps; % +eps to make sure the maximal value to be included
% change bin edge into matrix of (length(TempXValue) x length(TempData) x 2)
BinEdgeMtr = reshape(BinEdge, length(BinCenter), 1, 2);
BinEdgeMtr = repmat(BinEdgeMtr, 1, length(DataTrim), 1);

% change data into matrix of (length(TempXValue) x length(TempData) x 2)
if size(DataTrim, 1) ~= 1 % number of rows
    DataMtr = DataTrim';
else
    DataMtr = DataTrim;
end
DataMtr = ones(length(BinCenter), 1) * DataMtr;
DataMtr = repmat(DataMtr, 1, 1, 2);

% check whether the data is larger than the bondary
Check = (DataMtr > BinEdgeMtr);
% xor returns 1 only if  TempData(j) > TempBinEdge(i,1) & TempData(j) <= TempBinEdge(i,2)
Check = xor(Check(:,:,1), Check(:,:,2));
% number of each bin
BinNum = sum(Check, 2);

if true
    % get bin number with function hist()
    [N, BinC1] = hist(DataTrim, BinCenter);
    if size(N, 2) ~= 1
        N = N';
    end
    % check BinNum and N
    if any(BinNum-N)
        fprintf('NOTE: the number in each bin is different from hist()!\n');
        %[BinNum, N, BinNum-N]
        %[min(DataTrim), min(XValue), min(BinEdge(:,1,1))]
        %[max(DataTrim), max(XValue), max(BinEdge(:,1,1))]
    end
end

[RowN, ColN] = find(Check);
if length(BinInd) == length(RowN)
    BinVec(BinInd) = RowN;
end

end

