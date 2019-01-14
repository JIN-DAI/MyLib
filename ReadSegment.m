function SegmentOut = ReadSegment(Path, PDB)
%% READSEGMENT
% Description: get CA coordinates and temperature factors of the specified segment from pdb file.
%      Output: SegmentOut.CA         - CA struct from pdbread() for the specified segment
%              SegmentOut.Coords     - C-alpha coordinates of segment
%              SegmentOut.tempFactor - temperature factors of C-alpha atoms
%              SegmentOut.MSD        - mean squared displacement calculated from temperature factor
%       Input: Path        - path of the pdb file
%              PDB.model   - model id of segment in pdb file
%              PDB.chain   - chain id of segment in pdb file
%              PDB.segment - start and end residues' indice of segment in pdb file
% Author: J.Dai
% Created Date: 2015.01.19
% Last Modified Date: 2015.01.19


%% Default settings
% default PDB struct - first model, A chain and the whole chain
if nargin < 2
    PDB.model = 1;
    PDB.chain = 'A';
    PDB.segment = [-100 1e8];
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


%% Load pdb file and find C-alpha indice
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

% find Carbon Alpha's index in TargetModel
TempAtomNameList = {TargetModel.AtomName};
IndexCA = find(strcmp(TempAtomNameList, 'CA'));

% NOTE!!! only consider altLoc == '' OR 'A'; this can be modified to different requirements
% find altLoc == '' OR 'A' 
TempAltLoc = {TargetModel.altLoc};
IndexAltLoc = find(strcmp(TempAltLoc, '') + strcmp(TempAltLoc, 'A'));

% Carbon Alpha(CA) in Target Chain with altLoc == '' OR 'A'
IndexCAinChain = intersect(intersect(IndexCA, IndexTargetChain), IndexAltLoc);
TempCAinChain = TargetModel(IndexCAinChain);

% find CA in segment
TempResSeq = [TempCAinChain.resSeq];
IndexCAinSegment = find(TempResSeq >= PDB.segment(1) & TempResSeq <= PDB.segment(2));


%% ------------------------------------------------------------------------
% specified CA and add field 'CA' to SegmentOut
SegmentOut.CA = TempCAinChain(IndexCAinSegment);

% get coordinates and add field 'Coords' to SegmentOut
SegmentOut.Coords = [[SegmentOut.CA.X]' [SegmentOut.CA.Y]' [SegmentOut.CA.Z]'];

% get temperature factor and add field 'tempFactor' to SegmentOut
SegmentOut.tempFactor = [SegmentOut.CA.tempFactor]';

% calculate mean squared diplacement from temperature factor @MyLib and add field 'MSD' to SegmentOut
SegmentOut.MSD = CalculateMeanSquaredDisplacement(SegmentOut.tempFactor);


end

