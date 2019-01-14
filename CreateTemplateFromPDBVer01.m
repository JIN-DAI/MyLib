function template = CreateTemplateFromPDBVer01(SrcPDBPath, PDB, Type)
%CREATETEMPLATEFROMPDB Summary of this function goes here
%   Detailed explanation goes here


%%
% default Type value
if nargin < 3
    Type = 'CA';
end

switch Type
    case 'CA' % carbon-alpha atoms
        TargetAtomNameSet = {'CA'};
    case 'BB' % backbone atoms
        TargetAtomNameSet = {'N', 'CA', 'C', 'O'};
    case 'AA' % all-atom except hydrogen atoms
        TargetAtomNameSet = {'H'};
    otherwise
        Type = 'CA';
        TargetAtomNameSet = {'CA'};
end


%%
TempProtein = pdbread(SrcPDBPath);

% find Target model --> TargetModel = [TempProtein.Model.Atom]
if isnan(PDB.model)
    TargetModel = TempProtein.Model.Atom;
else
    TargetModel = TempProtein.Model(PDB.model).Atom;
end

% find Target chain's index in TargetModel
TempChainList = [TargetModel.chainID];
IndexTargetChain = find(TempChainList == PDB.chain);

% find Target atom's index in TargetModel
TempAtomNameList = {TargetModel.AtomName};
TargetAtomNameList = zeros(1, length(TempAtomNameList));
if strcmp(Type, 'AA')
    % remove the site of hydrogen atoms
    TargetAtomNameList = ~TargetAtomNameList;
    for iAtom = 1:length(TargetAtomNameSet)
        TargetAtomNameList = TargetAtomNameList - strncmp(TempAtomNameList, TargetAtomNameSet{iAtom}, length(TargetAtomNameSet{iAtom}));
    end
else
    % get the site of target atoms
    for iAtom = 1:length(TargetAtomNameSet)
        TargetAtomNameList = TargetAtomNameList + strcmp(TempAtomNameList, TargetAtomNameSet{iAtom});
    end
end
IndexTargetAtom = find(TargetAtomNameList);

% target atom in target chain
TempTargetAtominChain = TargetModel(intersect(IndexTargetAtom, IndexTargetChain));

% find target atom in segment
TempResSeq = [TempTargetAtominChain.resSeq];
IndexTargetAtominSegment = (TempResSeq >= PDB.segment(1) & TempResSeq <= PDB.segment(2));

% specified Target Atom
TargetAtominSegment = TempTargetAtominChain(IndexTargetAtominSegment);


%%
% string for Remark
RemarkString = [blanks(60); blanks(60)];
% line 1 for function name and date
TempString = sprintf('Template created by CreateTemplateFromPDB() on %s', date);
RemarkString(1,1:length(TempString)) = TempString;
% line 2 for the detail template information: entry-{chainID}-[modelID]-<SegmentStart SegmentEnd>
TempString = sprintf('Template of %s-{chain %s}', PDB.entry, PDB.chain);
if ~isnan(PDB.model)
    TempString = [TempString sprintf('-[model %02d]', PDB.model)];
end
TempString = [TempString sprintf('-<from %03d to %03d>-(%s)', PDB.segment(1), PDB.segment(2), Type)];
RemarkString(2,1:length(TempString)) = TempString;

% structure of empty Terminal
EmptyTerminal.SerialNo = NaN;
EmptyTerminal.resName = '';
EmptyTerminal.chainID = '';
EmptyTerminal.resSeq = NaN;
EmptyTerminal.iCode = '';

% template
template.Remark999 = RemarkString;
template.Model.Atom = TargetAtominSegment;
template.Model.Terminal = EmptyTerminal;


end

