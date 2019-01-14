function SegmentOut = ReadSegmentEX(Path, PDB, AtomType, AltLocSwitch)
%% READSEGMENTEX
% Description: get specified atoms' coordinates and temperature factors of the specified segment from pdb file.
%      Output: SegmentOut.Atom       - Atom struct from pdbread() for the specified segment
%              SegmentOut.Coords     - Atom's coordinates of segment
%              SegmentOut.tempFactor - temperature factors of atoms
%              SegmentOut.MSD        - mean squared displacement calculated from temperature factor
%       Input: Path        - path of the pdb file
%              PDB.model   - model id of segment in pdb file
%              PDB.chain   - chain id of segment in pdb file
%              PDB.segment - start and end residues' indice of segment in pdb file
%              AtomType    - specify the target atom's name
%              AltLocSwitch- turn on or off the screen of altLoc
% Author: J.Dai
% Created Date: 2015.07.24
% Last Modified Date: 2017.07.19


%% Default settings
% default AltLoc Switch
if nargin < 4
    AltLocSwitch = true;
end

% default Atom Type
if nargin < 3
    AtomType = 'CA';
end

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


%% Load pdb file and find Atom's indice
% load pdb file
TempProtein = pdbread(Path);

if ~isfield(TempProtein, 'Model') || ~isfield(TempProtein.Model, 'Atom')
    SegmentOut = [];
    return;
end

% find Target model --> TargetAtoms = [TempProtein.Model.Atom]
if isnan(PDB.model)
    TargetAtoms = TempProtein.Model.Atom;
else
    TargetAtoms = TempProtein.Model(PDB.model).Atom;
end

% find Target chain's index in TargetModel
TempChainList = [TargetAtoms.chainID];
if ~isempty(PDB.chain)
    IndexTargetChain = find(TempChainList == PDB.chain);
else
    IndexTargetChain = find(ones(size(TempChainList)));
end


% find Atoms' index in TargetModel
TempAtomNameList = {TargetAtoms.AtomName};
IndexCA = find(strcmp(TempAtomNameList, AtomType));

if AltLocSwitch
    % NOTE!!! only consider altLoc == '' OR 'A'; this can be modified to different requirements
    % find altLoc == '' OR 'A'
    TempAltLoc = {TargetAtoms.altLoc};
    IndexAltLoc = find(strcmp(TempAltLoc, '') + strcmp(TempAltLoc, 'A'));
    % Atoms in Target Chain with altLoc == '' OR 'A'
    IndexCAinChain = intersect(intersect(IndexCA, IndexTargetChain), IndexAltLoc);
else
    % Atoms in Target Chain
    IndexCAinChain = intersect(IndexCA, IndexTargetChain);
end

TempCAinChain = TargetAtoms(IndexCAinChain);

% find atoms in segment
TempResSeq = [TempCAinChain.resSeq];
IndexCAinSegment = find(TempResSeq >= PDB.segment(1) & TempResSeq <= PDB.segment(2));


%% ------------------------------------------------------------------------
% specified Atom and add field 'Atom' to SegmentOut
SegmentOut.Atom = TempCAinChain(IndexCAinSegment);

% get coordinates and add field 'Coords' to SegmentOut
SegmentOut.Coords = [[SegmentOut.Atom.X]' [SegmentOut.Atom.Y]' [SegmentOut.Atom.Z]'];

% get temperature factor and add field 'tempFactor' to SegmentOut
SegmentOut.tempFactor = [SegmentOut.Atom.tempFactor]';

% calculate mean squared diplacement from temperature factor @MyLib and add field 'MSD' to SegmentOut
SegmentOut.MSD = CalculateMeanSquaredDisplacement(SegmentOut.tempFactor);


end

