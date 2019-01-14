function CBetaOut = ReadCBetaAtoms(Path, PDB)
%% READCBETAATOMS
% Description: get C-Beta atoms' coordinates and temperature factors of the specified segment from pdb file.
%      Output: CBetaOut.Atom       - Atom struct from pdbread() for the specified segment
%              CBetaOut.Coords     - Atom's coordinates of segment
%              CBetaOut.tempFactor - temperature factors of atoms
%              CBetaOut.MSD        - mean squared displacement calculated from temperature factor
%       Input: Path        - path of the pdb file
%              PDB.model   - model id of segment in pdb file
%              PDB.chain   - chain id of segment in pdb file
%              PDB.segment - start and end residues' indice of segment in pdb file
% Author: J.Dai
% Created Date: 2015.12.14
% Last Modified Date: 2015.12.14


%% Default settings
% default PDB struct - first model, A chain and the whole chain
if nargin < 2 || isempty(PDB)
    PDB.model = 1;
    PDB.chain = 'A';
    PDB.segment = [-1 1e8];
else
    if ~isfield(PDB, 'model')
        PDB.model = 1;  
    end
    if ~isfield(PDB, 'chain')
        PDB.chain = 'A';
    end
    if ~isfield(PDB, 'segment')
        PDB.segment = [-100 1e8];
    end
end


% check PDB struct's field
FieldsName = {'model', 'chain', 'segment'};
if ~all(isfield(PDB, FieldsName))
%     fprintf('ERROR: missing field-{ ')
%     fprintf('''%s'' ', FieldsName{~isfield(PDB, FieldsName)});
%     fprintf('} in PDB struct!\n');
%     SegmentOut = [];
%     return;
    error('Missing field ''%s'' in PDB struct!\n', FieldsName{~isfield(PDB, FieldsName)});
end

% check pdb file's extention
PDB_Extension = '.pdb';
[~, ~, file_ext] = fileparts(Path);
if ~strcmp(file_ext, PDB_Extension)
    error('Wrong pdb file extension in ''%s''!\n', Path);
end


%% Load pdb file and find C-beta indice
% load pdb file
TempProtein = pdbread(Path);

% find Target model --> TargetModel = [TempProtein.Model.Atom]
if isnan(PDB.model)
    TargetModel = TempProtein.Model.Atom;
else
    TargetModel = TempProtein.Model(PDB.model).Atom;
end

% find Target chain's index in TargetModel
TempChainList = [TargetModel.chainID];
IndexTargetChain = find(TempChainList == PDB.chain);

% find Target segment's index in TargetModel
TempResSeqList = [TargetModel.resSeq];
IndexTargetSegment = find(TempResSeqList >= PDB.segment(1) & TempResSeqList <= PDB.segment(2));

% remove hydrogen atoms
TempAtomNameList = [TempProtein.Model.Atom.AtomNameStruct];
TempStartIndex = regexp({TempAtomNameList.chemSymbol}, '\d*H|[0-9]');
IndexNonHAtoms = find(cellfun(@isempty, TempStartIndex));

% get target segment in target chain and also remove hydrogen atoms
IndexSegInChain = intersect(intersect(IndexTargetChain, IndexTargetSegment), IndexNonHAtoms);


%% CB Atom Struct in GLY
CBAtomInGLY.AtomSerNo = nan;
CBAtomInGLY.AtomName = 'CB';
CBAtomInGLY.altLoc = '';
CBAtomInGLY.resName = 'GLY';
CBAtomInGLY.chainID = '';
CBAtomInGLY.resSeq = nan;
CBAtomInGLY.iCode = '';
CBAtomInGLY.X = nan;
CBAtomInGLY.Y = nan;
CBAtomInGLY.Z = nan;
CBAtomInGLY.occupancy = 1;
CBAtomInGLY.tempFactor = nan;
CBAtomInGLY.segID = '    ';
CBAtomInGLY.element = '';
CBAtomInGLY.charge = '  ';
CBAtomInGLY.AtomNameStruct.chemSymbol = 'C';
CBAtomInGLY.AtomNameStruct.remoteInd = 'B';
CBAtomInGLY.AtomNameStruct.branch = '';


%% ------------------------------------------------------------------------
TempCounter = 0;
TempLastGLYRes = -1e5;

% max initialize dimension
MaxN = 1e3;
TempCoords = nan(MaxN, 3);
TempTempFactor = nan(MaxN, 1);
TempMSD = nan(MaxN, 1);

for iAtom = IndexSegInChain
    TempAtom = TargetModel(iAtom);
    if ~strcmp(TempAtom.resName, 'GLY')
        if strcmp(TempAtom.AtomName, 'CB') && ...
           (strcmp(TempAtom.altLoc, '') || strcmp(TempAtom.altLoc, 'A'))
            TempCounter = TempCounter + 1;
            
            % specified Atom
            TempAtomALL(TempCounter) = TempAtom;
            % get coordinates
            TempCoords(TempCounter,:) = [TempAtom.X TempAtom.Y TempAtom.Z];
            % get temperature factor
            TempTempFactor(TempCounter,1) = TempAtom.tempFactor;            
            % calculate mean squared diplacement from temperature factor @MyLib
            TempMSD(TempCounter,1) = CalculateMeanSquaredDisplacement(TempAtom.tempFactor);
        end
        
    elseif (TempLastGLYRes ~= TempAtom.resSeq)
        TempCounter = TempCounter + 1;
        
        % specified Atom
        TempAtomALL(TempCounter) = CBAtomInGLY;
        TempAtomALL(TempCounter).chainID = TempAtom.chainID;
        TempAtomALL(TempCounter).resSeq = TempAtom.resSeq;
        % get coordinates
        TempCoords(TempCounter,:) = [nan nan nan];
        % get temperature factor
        TempTempFactor(TempCounter,1) = nan;
        % calculate mean squared diplacement from temperature factor @MyLib
        TempMSD(TempCounter,1) = nan;
        
        TempLastGLYRes = TempAtom.resSeq;
    end
end

% initialize CBetaOut
CBetaOut = struct('Atom', [], 'Coords', [], 'tempFactor', [], 'MSD', []);
% add field 'Atom'
CBetaOut.Atom = TempAtomALL;
% add field 'Coords'
CBetaOut.Coords = TempCoords(1:TempCounter,:);
% add field 'tempFactor'
CBetaOut.tempFactor = TempTempFactor(1:TempCounter);
% add field 'MSD'
CBetaOut.MSD = TempMSD(1:TempCounter);


end

