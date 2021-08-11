% number of points
N = 30;

% fix first angles, left 2*(N-2) degrees of freedom
objFunc = @(x) -Hamiltonian([0, pi/2, x]);

opts = optimset('fminsearch');
%opts = optimset('PlotFcns',@optimplotfval);
%opts.Display = 'none';
opts.TolFun = 1e-12;
opts.TolX = 1e-12;
opts.MaxIter = 1e14;
opts.MaxFunEvals = 1e14;

LB = repmat([0, 0], 1, N-2);
UB = repmat([2*pi, pi], 1, N-2);

%%
maxRunN = 1;
runVal = nan(maxRunN,1);
runXsol = nan(maxRunN, 2*(N-2));

parfor i = 1:maxRunN
    x0 = nan(1,2*(N-2));
    x0(1:2:end) = 2*pi*rand(1,N-2); % random phi
    x0(2:2:end) = pi*rand(1,N-2); % random theta
    
    [xsol,fval,exitflag,output] = fminsearchbnd(objFunc, x0, LB, UB, opts);
    
    runVal(i) = fval;
    runXsol(i,:) = xsol;
end

%%
minId = find(runVal == min(runVal));
if numel(minId) > 1
    fprintf('Number of min is larger than 1!\n');
    minId = minId(1);
end

minVal = runVal(minId);
minXsol = runXsol(minId,:);

%%
Angles = [0, pi/2, minXsol];
minE = Hamiltonian(Angles);
Angles = reshape(Angles, 2, [])';

T = [cos(Angles(:,1)).*sin(Angles(:,2)), sin(Angles(:,1)).*sin(Angles(:,2)), cos(Angles(:,2))];
R = zeros(N,3);
delta = 1;
for i = 1:size(T,1)
    R(i+1,:) = R(i,:)+delta*T(i,:);
end

%%
CreateFigure(sprintf('MinR_N=%d_E=%f', N, minE), [200, 50, 800, 800]);
    
plot3(R(:,1),R(:,2),R(:,3), 'bo-', 'LineWidth', 2, 'MarkerSize', 12', 'MarkerFaceColor', 'b');

% text
for i = 1:N
    text(R(i,1),R(i,2),R(i,3), sprintf('P%d',i), 'FontSize', 16, 'Interpreter', 'latex');
end

axis tight;
axis equal;
box on;
rotate3d on;