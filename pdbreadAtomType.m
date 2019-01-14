function Atom = pdbreadAtomType(FilePath, AtomTypeList)
%PDBREADATOMTYPE Summary of this function goes here
%   Detailed explanation goes here

%%
% read from pdb file
PDBStruct = pdbread(FilePath);
if isempty(PDBStruct)
    error('Error occurs while reading %s!', FilePath);
end

% get model
Model = PDBStruct.Model;

% initialize index for atom type
IdxAtomType = zeros(1, numel({Model.Atom.AtomName}));
% get index for atoms in AtomTypeList % NOTE: how to vector
for iType = 1:numel(AtomTypeList)
    IdxAtomType = IdxAtomType | strcmp({Model.Atom.AtomName}, AtomTypeList{iType});
end

% atoms in specific chain
Atom = Model.Atom(IdxAtomType);

end

