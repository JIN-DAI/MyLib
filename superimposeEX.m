function [rmsd,dist,XX,YYQ,T,Q] = superimposeEX(X,Y,LapIndex,f,Width,Color)
%% superimposeEX.m
% ---INPUT---
% X and Y are two curves' coordinates matrices
% LapIndex: in which part of X and Y should be overlapped
% f is plotting handle, 1 - detailed; 2 - for publication; other - no plotting
% Width: linewidth for plotting curves
% Color: linecolor for plotting curves
% ---OUTPUT---
% rmsd: their distance
% dist: distance of corresponding point
% XX: X curve's coordinates matrices after translating its center to original point
% YYQ: Y curve's coordinates matrices after translation and rotation
% T, Q: translate vector and rotation matrices

%% default arguements
% default line color
if nargin < 6
    Color = ['r' 'b'];
end
% default line width
if nargin < 5
    Width = [2 1.5];
end
% default plotting handle
if nargin < 4
    f = 0;
end
% default LapIndex
if nargin < 3 || isempty(LapIndex)
    LapIndex = [1:min(max(size(X)), max(size(Y)))];
end
% check whether the matrices' shape of X and Y are Nx3
xl = 0; % variable to record whether X is transposed
yl = 0; % variable to record whether Y is transposed
[m,n] = size(X);
if n>3
    X = X';
    xl = 1;
end
[mm,nn] = size(Y);
if nn>3
    Y = Y';
    yl = 1;
end

%%
% number of common atoms
num_atoms = min(max(size(X)), max(size(Y)));
% check the overlapped index
CheckIndex = LapIndex > num_atoms | LapIndex < 1;
if sum(CheckIndex) > 0
    % index out of range
    fprintf('Overlapped index out of range:\n');
    for i = find(CheckIndex)
        fprintf('%d ', LapIndex(i));
    end
    fprintf('\n');
    % index for overlapped
    LapIndex = LapIndex(~CheckIndex);
    fprintf('Overlapped index is:\n');
    for i = 1:length(LapIndex)
        fprintf('%d ', LapIndex(i));
    end
    fprintf('\n');
end
LapNum = length(LapIndex);

LapX = X(LapIndex,:); % overlapped part
LapXC = sum(LapX)/LapNum; % center of overlapped part
% move X curve
XX(:,1) = X(:,1) - LapXC(1);
XX(:,2) = X(:,2) - LapXC(2);
XX(:,3) = X(:,3) - LapXC(3);
% overlapped part of X after moving
LapXX = XX(LapIndex,:);

LapY = Y(LapIndex,:); % overlapped part
LapYC = sum(LapY)/LapNum; % center of overlapped part
% move Y curve
YY(:,1) = Y(:,1) - LapYC(1);
YY(:,2) = Y(:,2) - LapYC(2);
YY(:,3) = Y(:,3) - LapYC(3);
% overlapped part of Y after moving
LapYY = YY(LapIndex,:);

[TempRmsd, TempDist, TempXX, TempYYQ, LapT, LapQ] = superimpose(LapXX, LapYY);

% translation vector
T = LapXC - LapYC;
% rotaion matrix
Q = LapQ;
% curve Y after rotation
YYQ = YY*LapQ;
% atom distance
for indx = 1:length(YYQ)
    dist(indx) = norm(YYQ(indx,:)-XX(indx,:));
end
% rmsd
rmsd = sqrt(sum(sum((XX - YYQ).^2))/num_atoms);

%% plotting and outputing
if f == 1 %ploting result
    %subplot(2,1,1)
    %figure,hold on
    figure('Color', 'w');
    plot3(XX(:,1), XX(:,2), XX(:,3), [Color(1), '-'], 'LineWidth', Width(1))
    hold on;
    plot3(YYQ(:,1), YYQ(:,2), YYQ(:,3), [Color(2), '-'], 'LineWidth', Width(2))
    box on;
    axis equal;
    rotate3d on
%     legend('x','rotating y')
%     title(['RMSD = ' num2str(rmsd)])
%     subplot(2,1,2)
%     plot(dist)
%     title('the distance between corresponding points on two curves')
end
if f == 2 %ploting result for publication setting
    figure('Color', 'w');
    hnd=plot3([XX(:,1) YYQ(:,1)], [XX(:,2) YYQ(:,2)], [XX(:,3) YYQ(:,3)], 'LineWidth', 6);
    set(hnd(1),'Color',[0.5 0 0]);
    set(hnd(2),'Color',[0 0 0.5]);
    rotate3d on;
    axis equal, axis off;
    box off;
    legend off;
end


%% restore the shape of XX and YYQ to X and Y
if xl==1
    XX=XX';
end
if yl==1
    YYQ=YYQ';
end

end

