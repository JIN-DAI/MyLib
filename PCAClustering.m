function [KMeansRes, Transition] = PCAClustering(PCA, KMeansPar, TransShift, ShowLog)
%% PCACLUSTERING 
% Description: 1.run k-means clustering in first n-th PC space and calculate geometric and kinetic quantities
%              2.calculate transition matrix between each cluster
% Author: J.Dai
% Created Date: 2017.06.26
% Last Modified Date: 2017.06.26


%% default input values
% print log
if nargin < 4
    ShowLog = false;
end

% shift frame in calculate transition matrix
if nargin < 3 || isempty(TransShift)
    TransShift = 1;
end

% parameters of kmeans
if nargin < 2 || isempty(KMeansPar)
    KMeansPar.CenterNumber = 1:10;
    KMeansPar.MaxReplicatesTime = 100;
    KMeansPar.PCNumber = 1:6;
    KMeansPar.DisplayOpt = 'off';
end


%% initialization of outputs
% result of kmeans
KMeansRes.ClusterIndex = cell(numel(KMeansPar.CenterNumber),1); % cluster indice of each frames
KMeansRes.CentroidLoc  = cell(numel(KMeansPar.CenterNumber),1); % centroid location of each cluster
KMeansRes.Geometric    = cell(numel(KMeansPar.CenterNumber),1); % mean variance each cluster
KMeansRes.Kinetic      = cell(numel(KMeansPar.CenterNumber),1); % eigenvalues of transition matrix
KMeansRes.SumD         = cell(numel(KMeansPar.CenterNumber),1);
KMeansRes.Timer        = nan(numel(KMeansPar.CenterNumber),1);

% transition
Transition.Shift = TransShift; % shifted frames
Transition.Matrix = cell(numel(KMeansPar.CenterNumber),1); % transition matrix


%% run k-means clustering in first n-th PC space and also judge the clustering results with Criteria(Geometric and Kinetic)
WaitBarString = 'K-means clustering';
if strncmp(computer('arch'), 'win', 3)
    % ------ %
    % --- Waitbar ---
    % handle of waitbar and setting Cancel button
    WaitBarHandle = waitbar(0, '0%', 'Name', [WaitBarString  '...'],...
        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
    setappdata(WaitBarHandle, 'canceling', 0);
    % ---------------
end

for iK = 1:numel(KMeansPar.CenterNumber)
    if ShowLog
        % print information of number of centers
        fprintf('Start k-means with number of centers = %d\n', KMeansPar.CenterNumber(iK));
    end
        
    % ---------------------------------------------------------------------
    if strncmp(computer('arch'), 'win', 3)
        % --- Waitbar ---
        % check for Cancel button press
        if getappdata(WaitBarHandle, 'canceling')
            fprintf('WARNING: <%s> is cancelled at %d/%d!\n', WaitBarString, iK-1, numel(KMeansPar.CenterNumber));
            % delete waitbar
            delete(WaitBarHandle);
            return;
        else
            % Report current estimate in the waitbar's message field
            Progress = iK/numel(KMeansPar.CenterNumber);
            waitbar(Progress, WaitBarHandle, sprintf('%d%%',fix(100*Progress)));
        end
        % ---------------
    end
    % ---------------------------------------------------------------------
    
    % start timer
    tic;
    
    % run k-means
    [IDX,Ctr,SumD] = kmeans(PCA.score(:,KMeansPar.PCNumber), KMeansPar.CenterNumber(iK), ...
                            'Replicates', KMeansPar.MaxReplicatesTime, 'Display', KMeansPar.DisplayOpt);
    
    % store indices and centers
    KMeansRes.ClusterIndex{iK} = IDX;
    KMeansRes.CentroidLoc{iK} = Ctr;
    KMeansRes.SumD{iK} = SumD;
    
    % ---------------------------------------------------------------------
    % number of clusters
    ClusterIndex = unique(IDX);
    
    % mean variance in every clusters]
    MeanVar = nan(size(ClusterIndex));
    switch PCA.Type
        case 'Cartesian' % variance on Cartesian coordinates
            for iC = 1:numel(ClusterIndex)
                % frame index in iC-th cluster
                IdxC = find(IDX == ClusterIndex(iC));
                % mean variance
                MeanVar(iC) = mean(std(PCA.Var(IdxC,:),1));
            end
        case {'FrenetDirect', 'DihedralDirect'} % circular variance on angles
            for iC = 1:numel(ClusterIndex)
                % frame index in iC-th cluster
                IdxC = find(IDX == ClusterIndex(iC));
                % mean variance
                R = sqrt(sum(cos(PCA.Var(IdxC,:))).^2 + sum(sin(PCA.Var(IdxC,:))).^2);
                MeanVar(iC) = mean(1-R/numel(IdxC));
            end
        case {'FrenetTrans', 'DihedralTrans'} % circular variance on sin- and cos-transformed angles
            for iC = 1:numel(ClusterIndex)
                % frame index in iC-th cluster
                IdxC = find(IDX == ClusterIndex(iC));
                % mean variance
                R = sqrt(sum(PCA.Var(IdxC,1:2:end)).^2 + sum(PCA.Var(IdxC,2:2:end)).^2);
                MeanVar(iC) = mean(1-R/numel(IdxC));
            end
    end
    % ---------------------------------------------------------------------
    % record mean variance
    KMeansRes.Geometric{iK} = MeanVar;
    
    % ---------------------------------------------------------------------
    % current state: each row is a one-hot vector indicate which cluster it belongs to
    StateMat = zeros(numel(IDX), numel(ClusterIndex));
    StateMat((1:numel(IDX))' + (IDX-1)*numel(IDX)) = 1;
    
    % one direction count
    % counter_ij: i state at t -> j state at (t+shift)
    CiCj = StateMat(1:(end-Transition.Shift),:)'*StateMat((1+Transition.Shift):end,:);
    if true
        % symmetrization by considering two directions
        % counter_ij: i state at t -> j state at (t+shift) + j state at t -> i state at (t+shift)
        CiCj = CiCj + CiCj';
    end
    % transition matrix (row stochastic transition matrix)
    % normalizing CiCj so that the sum over a row is unity
    Transition.Matrix{iK} = CiCj./repmat(sum(CiCj,2), 1, size(CiCj, 2));
    % ---------------------------------------------------------------------
    % record eigenvalues
    KMeansRes.Kinetic{iK} = eigs(Transition.Matrix{iK}, KMeansPar.CenterNumber(iK));
        
    % record run time
    KMeansRes.Timer(iK) = toc;
    
    if ShowLog
        fprintf('Best total sum of distances = %f\n', sum(SumD));
        fprintf('Elapsed time is %f seconds.\n\n', KMeansRes.Timer(iK));
    end
end


if strncmp(computer('arch'), 'win', 3)
    % --- Waitbar ---
    % delete waitbar
    delete(WaitBarHandle);
    % ---------------
    % ------ %
end


end

