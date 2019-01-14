function RMSF = CalculateRMSF_Traj(Coords, Ref, Fit)
%% CALCULATERMSF_TRAJ
% Description: calculate Root-Mean-Squared-Fluctuation over trajectory
% Author: Jin Dai
% Created Date: 2017.05.10
% Last Modified Date: 2017.05.10


%%
if nargin < 3 || isempty(Fit)
    Fit = true;
end

if nargin < 2 || isempty(Ref)
    Ref = 'Mean';
end


%%
switch ndims(Coords)
    case 2
        [N_RES,N_FRAME] = size(Coords);
        N_FRAME = N_FRAME/3;
        Coords = reshape(Coords, [N_RES, 3, N_FRAME]);
    case 3
        [N_RES,~,N_FRAME] = size(Coords);
    otherwise
        fprintf('ERROR: the dimensions of coordinates matrix is not correct!\n');
        RMSF = [];
        return;
end

% meaning of each dimension in Coords
% -1st dimension: atom
% -2nd dimension: xyz
% -3rd dimension: frame


%% superpose structure to minimize rmsd
if Fit
    % take the first frame as the reference structure
    [~,~,TargetCoords] = superimpose(Coords(:,:,1), Coords(:,:,1));
    
    for i = 1:N_FRAME
        [~,~,~,TempCoords] = superimpose(TargetCoords, Coords(:,:,i));
        Coords(:,:,i) = TempCoords;
    end
end


%% calculate Root-Mean-Squared-Fluctuation for each atoms
switch Ref
    case {'Mean', 'mean'}
        CoordsRef = mean(Coords, 3);
    case {'Initial', 'Init'}
        CoordsRef = Coords(:,:,1);
    otherwise
        fprintf('ERROR: can not specify the reference!\n');
        RMSF = [];
        return;
end

% difference matrix: Mat_{Traj} - Mat_{Ref}
DiffMat = Coords - repmat(CoordsRef,1,1,size(Coords,3));

% divide difference matrix by atom; each cell represent one atom:
% -1st dimension in cell: frame
% -2nd dimension in cell: xyz
DiffCell = cellfun(@squeeze, mat2cell(DiffMat, ones(N_RES,1)), 'UniformOutput', false);

% calculate RMSF
RMSF = cellfun(@(X) sqrt(sum(diag(X*X'))/N_FRAME), DiffCell, 'UniformOutput', false);
RMSF = cell2mat(RMSF);


end

