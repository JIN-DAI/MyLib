function [rmsd,dist,XX,YYQ,T,Q] = superimpose(X,Y,f,Width,Color,RotationMatrixSwitch) 
%% superimpose.m
% reference link: http://boscoh.com/protein/rmsd-root-mean-square-deviation.html
% ---INPUT---
% X and Y are two curves' coordinates matrices
% f is plotting handle, 1 - detailed; 2 - for publication; other - no plotting
% Width: linewidth for plotting curves
% Color: linecolor for plotting curves
% RotationsMatrixSwitch: true - determinant of Q is always positive, false - determinant of Q can be negative
% NOTE: Bug in this parameter!
% ---OUTPUT---
% rmsd: their distance
% dist: distance of corresponding point
% XX: X curve's coordinates matrices after translating its center to original point
% YYQ: Y curve's coordinates matrices after translation and rotation
% T, Q: translate vector and rotation matrices

%% default arguements
% default RotationMatrixSwitch
if nargin<6
    RotationMatrixSwitch = true;
end
% default line color
if nargin<5 || isempty(Color)
    Color = ['r' 'b'];
end
% default line width
if nargin<4 || isempty(Width)
    Width = [2 1.5];
end
% default plotting handle
if nargin<3 || isempty(f)
    f = 0;
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
num_atoms = min(max(size(X)), max(size(Y))); % number of common atoms
% take common atoms from the first
X = X(1:num_atoms, :);
Y = Y(1:num_atoms, :);

% geometry center of curves
xc = sum(X) / num_atoms;
yc = sum(Y) / num_atoms;
% move X's center to original point
XX(:, 1) = X(:, 1) - xc(1);
XX(:, 2) = X(:, 2) - xc(2);
XX(:, 3) = X(:, 3) - xc(3);
% move Y's center to original point
YY(:, 1) = Y(:, 1) - yc(1);
YY(:, 2) = Y(:, 2) - yc(2);
YY(:, 3) = Y(:, 3) - yc(3);

% translation vector from Y center to X center
T = xc - yc;

% find the rotation matrix
C = YY' * XX;
[U, S, V] = svd(C);
% assure the rotation matrix has +1 determinant
uv = det(U)*det(V);
Cdet = det(C);
Si = [1 0 0;
      0 1 0;
      0 0 -1];
if Cdet>0 || ((Cdet==0) && (uv>0)) || (~RotationMatrixSwitch)
    Q = U * V';
elseif Cdet<0 || ((Cdet==0) && (uv<0)) 
    Q = U*Si*V';
end

rmsd = sqrt(sum(sum((XX - YY*Q).^2))/num_atoms);
YYQ = YY*Q;
for indx = 1:length(YYQ)
    dist(indx) = norm(YYQ(indx,:)-XX(indx,:));
end

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