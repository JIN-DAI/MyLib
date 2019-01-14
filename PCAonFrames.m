function PCA = PCAonFrames(Frames, VarType, FieldName)
%% PCAONFRAMES 
% Description: run PCA on Frames struct which is usually created from trajectory.
%            Possible choices for VarType:
%            -'Cartesian'     : PCA on Cartesian coordinates, field 'CoordsCA' is needed
%            -'FrenetDirect'  : PCA directly on Frenet Angles, field 'AnglesCA' is needed
%            -'FrenetTrans'   : PCA on sin- and cos-transformed Frenet Angles, field 'AnglesCA' is needed
%            -'DihedralDirect': PCA directly on backbone dihedral Angles, field 'AnglesBB' is needed
%            -'DihedralTrans' : PCA on sin- and cos-transformed backbone dihedral Angles, field 'AnglesBB' is needed
% Author: J.Dai
% Created Date: 2017.06.24
% Last Modified Date: 2017.06.24


%%
if nargin < 3
    FieldName = [];
end

PCA.Type = VarType;


%%
if ~isempty(FieldName) && ~isfield(Frames, FieldName)
    fprintf('Error: Frames does not include field ''%s''!\n', FieldName);
    PCA = [];
    return;
elseif ~isempty(FieldName)
    switch PCA.Type
        case 'Cartesian'
            for iF = 1:numel(Frames)
                Frames(iF).CoordsCA = Frames(iF).(FieldName);
            end
        case {'FrenetDirect','FrenetTrans'}
            for iF = 1:numel(Frames)
                Frames(iF).AnglesCA = Frames(iF).(FieldName);
            end
        case {'DihedralDirect', 'DihedralTrans'}
            for iF = 1:numel(Frames)
                Frames(iF).AnglesBB = Frames(iF).(FieldName);
            end
    end
end


%% Coordinates for PCA
switch PCA.Type
    case 'Cartesian' % PCA on Cartesian coordinates
        % check field
        if ~isfield(Frames, 'CoordsCA')
            fprintf('Error: Frames does not include field ''CoordsCA''!\n');
            PCA = [];
            return;
        end
        
        % initialize
        Coords = nan(numel(Frames), numel(Frames(1).CoordsCA));        
        % fit to the first frame
        [~,~,TargetCoords] = superimpose(Frames(1).CoordsCA, Frames(1).CoordsCA);
        for i = 1:numel(Frames)
            [~,~,~,TempCoords] = superimpose(TargetCoords, Frames(i).CoordsCA);
            TempCoords = CheckCoordsDim(TempCoords)';
            Coords(i,:) = TempCoords(:);
        end

        % variable index
        VarID = repmat((1:3)', 1, size(Frames(1).CoordsCA,1));
        % residue index
        ResID = repmat(1:size(Frames(1).CoordsCA,1), 3, 1);
        % tag: row1->variable index, row2->residue index
        Tag = [VarID(:)'; ResID(:)'];
        
        % remove corresponding column with nan
        Tag(:, isnan(Coords(1,:))) = [];
        % remove column with nan
        Coords(:,isnan(Coords(1,:))) = [];
        
        % PCA variable
        PCA.Var = Coords;
        PCA.Tag = Tag;
        
        clear Coords;
    case 'FrenetDirect' % PCA directly on Frenet Angles
        % check field
        if ~isfield(Frames, 'AnglesCA')
            fprintf('Error: Frames does not include field ''AnglesCA''!\n');
            PCA = [];
            return;
        end
        
        % initialzie
        FrenetAngles = nan(numel(Frames), numel(Frames(1).AnglesCA));
        % copy data
        for i = 1:numel(Frames)
            TempAngles = Frames(i).AnglesCA';
            FrenetAngles(i,:) = TempAngles(:);
        end
        
        % variable index
        VarID = repmat((1:2)', 1, size(Frames(1).AnglesCA,1));
        % residue index
        ResID = repmat(1:size(Frames(1).AnglesCA,1), 2, 1);
        % tag: row1->variable index, row2->residue index
        Tag = [VarID(:)'; ResID(:)'];
        
        % remove corresponding column with nan
        Tag(:, isnan(FrenetAngles(1,:))) = [];
        % remove column with nan
        FrenetAngles(:,isnan(FrenetAngles(1,:))) = [];
        
        % PCA variable
        PCA.Var = FrenetAngles;
        PCA.Tag = Tag;
        
        clear FrenetAngles;
    case 'FrenetTrans' % PCA on sin- and cos-transformed Frenet Angles
        % check field
        if ~isfield(Frames, 'AnglesCA')
            fprintf('Error: Frames does not include field ''AnglesCA''!\n');
            PCA = [];
            return;
        end
        
        % initialzie
        FrenetAnglesTrans = nan(numel(Frames), 2*numel(Frames(1).AnglesCA));
        % sin- and cos-transformation
        % [cos\kappa sin\kappa cos\tau sin\tau]_i
        for i = 1:numel(Frames)
            TempAngles = [cos(Frames(i).AnglesCA(:,1)), sin(Frames(i).AnglesCA(:,1)), ...
                          cos(Frames(i).AnglesCA(:,2)), sin(Frames(i).AnglesCA(:,2))]';
            FrenetAnglesTrans(i,:) = TempAngles(:);
        end
        
        % variable index
        VarID = repmat((1:4)', 1, size(Frames(1).AnglesCA,1));
        % residue index
        ResID = repmat(1:size(Frames(1).AnglesCA,1), 4, 1);
        % tag: row1->variable index, row2->residue index
        Tag = [VarID(:)'; ResID(:)'];
        
        % remove corresponding column with nan
        Tag(:, isnan(FrenetAnglesTrans(1,:))) = [];
        % remove column with nan
        FrenetAnglesTrans(:,isnan(FrenetAnglesTrans(1,:))) = [];
        
        % PCA variable
        PCA.Var = FrenetAnglesTrans;
        PCA.Tag = Tag;
        
        clear FrenetAnglesTrans;
    case 'DihedralDirect' % PCA directly on backbone dihedral Angles
        % check field
        if ~isfield(Frames, 'AnglesBB')
            fprintf('Error: Frames does not include field ''AnglesBB''!\n');
            PCA = [];
            return;
        end
        
        % initialzie
        DihedralAngles = nan(numel(Frames), numel(Frames(1).AnglesBB(:,[1,3])));
        % copy data
        for i = 1:numel(Frames)
            TempAngles = Frames(i).AnglesBB(:,[1,3])';
            DihedralAngles(i,:) = TempAngles(:);
        end
        
        % variable index
        VarID = repmat((1:2)', 1, size(Frames(1).AnglesBB,1));
        % residue index
        ResID = repmat(1:size(Frames(1).AnglesBB,1), 2, 1);
        % tag: row1->variable index, row2->residue index
        Tag = [VarID(:)'; ResID(:)'];
        
        % remove column with nan
        DihedralAngles(:,isnan(DihedralAngles(1,:))) = [];
        % remove corresponding column with nan
        Tag(:, isnan(DihedralAngles(1,:))) = [];
        
        % PCA variable
        PCA.Var = DihedralAngles;
        PCA.Tag = Tag;
        
        clear DihedralAngles;
    case 'DihedralTrans' % PCA on sin- and cos-transformed backbone dihedral Angles
        % check field
        if isempty(FieldName) && ~isfield(Frames, 'AnglesBB')
            fprintf('Error: Frames does not include field ''AnglesBB''!\n');
            PCA = [];
            return;
        end
        
        % initialzie
        DihedralAnglesTrans = nan(numel(Frames), 2*numel(Frames(1).AnglesBB(:,[1,3])));
        % sin- and cos-transformation
        % [cos\psi sin\psi cos\phi sin\phi]_i
        for i = 1:numel(Frames)
            TempAngles = [cos(Frames(i).AnglesBB(:,1)), sin(Frames(i).AnglesBB(:,1)), ...
                          cos(Frames(i).AnglesBB(:,3)), sin(Frames(i).AnglesBB(:,3))]';
            DihedralAnglesTrans(i,:) = TempAngles(:);
        end
                
        % variable index
        VarID = repmat((1:4)', 1, size(Frames(1).AnglesBB,1));
        % residue index
        ResID = repmat(1:size(Frames(1).AnglesBB,1), 4, 1);
        % tag: row1->variable index, row2->residue index
        Tag = [VarID(:)'; ResID(:)'];
        
        % remove column with nan
        DihedralAnglesTrans(:,isnan(DihedralAnglesTrans(1,:))) = [];
        % remove corresponding column with nan
        Tag(:, isnan(DihedralAnglesTrans(1,:))) = [];
        
        % PCA variable
        PCA.Var = DihedralAnglesTrans;
        PCA.Tag = Tag;
        
        clear DihedralAnglesTrans;
    otherwise
        fprintf('Error: unable to deal with variable type ''%s''!\n', VarType);
        PCA = [];
        return;
end
% PCA
[PCA.coeff,PCA.score,PCA.latent] = pca(PCA.Var);


%% Normalized Autocorrelation of PC-scores
% NOTE: discrete autocorrelation definition should be checked carefully in future!!!
PCA.AutoCorr = nan(size(PCA.score));

Score = PCA.score;
% centralization
Score = Score - repmat(mean(Score), size(Score,1), 1);

ScoreVar = var(Score, 1);
for iShift = 1:size(Score, 1)+1
    ShiftScore = zeros(size(Score));
    ShiftScore(iShift:end,:) = Score(1:end-iShift+1,:);
    PCA.AutoCorr(iShift,:) = mean(Score.*ShiftScore)./ScoreVar;
end


end

