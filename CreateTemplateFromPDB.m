function template = CreateTemplateFromPDB(SrcPDBPath, PDB, Type)
%% CREATETEMPLATEFROMPDB
% Description: get template PDB struct specified by PDB and Type
% Author: J.Dai
% Created Date: 2014.12.05
% Last Modified Date: 2015.03.13


%% default arguments
% default Type value
if nargin < 3 || isempty(Type)
    Type = 'CA';
end
% set TargetAtomNameSet according to Type
switch Type
    case 'CA' % carbon-alpha atoms
        TargetAtomNameSet = {'CA'};
    case 'BB' % backbone atoms
        TargetAtomNameSet = {'N', 'CA', 'C', 'O'};
    case 'AA' % all-atom except hydrogen atoms
        TargetAtomNameSet = {'H'};
    case 'CACB' % carbon-alpha atoms and carbon-beta atoms
        TargetAtomNameSet = {'CA', 'CB'};
    otherwise % default atoms set
        TargetAtomNameSet = {'CA'};
end

if nargin < 2 || isempty(PDB)
    PDB.entry = 'Unkown';
    PDB.model = 1;
    PDB.chain = 'A';
    PDB.segment = [-inf, +inf];
end
if ~isfield(PDB, 'entry')
    PDB.entry = 'Unkown';
end
if ~isfield(PDB, 'model')
    PDB.model = 1;
end
if ~isfield(PDB, 'chain')
    PDB.chain = 'A';
end
if ~isfield(PDB, 'segment')
    PDB.segment = [-inf, +inf];
end


%% get specified atoms' struct
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

% find Target atoms' index in TargetModel
TempAtomNameList = {TargetModel.AtomName};
TargetAtomNameList = zeros(1, length(TempAtomNameList));
if strcmp(Type, 'AA')
    % include all atoms for default
    TargetAtomNameList = ~TargetAtomNameList;
    % get the chemical symbol of all atoms
    TempAtomNameStruct = [TargetModel.AtomNameStruct];
    TempChemSymbol = {TempAtomNameStruct.chemSymbol};   
    % remove the atoms in the atom set
    for iAtom = 1:length(TargetAtomNameSet)
        % get the target atom name
        TempAtomName = TargetAtomNameSet{iAtom};
        % -----------------------------------------------------------------
        % exclude the atom with the same name
        %TargetAtomNameList = (TargetAtomNameList & ~strncmp(TempAtomNameList, TempAtomName, length(TargetAtomNameSet{iAtom})));
        % -----------------------------------------------------------------
        % exclude the same kind of atom
        TargetAtomNameList = (TargetAtomNameList & cellfun(@isempty, strfind(TempChemSymbol, TempAtomName(1))));
    end
else
    % get the site of target atoms
    for iAtom = 1:length(TargetAtomNameSet)
        TargetAtomNameList = (TargetAtomNameList | strcmp(TempAtomNameList, TargetAtomNameSet{iAtom}));
    end
end
IndexTargetAtom = find(TargetAtomNameList);

% NOTE!!!  only consider altLoc == '' OR 'A'; this can be modified to different requirements
% find altLoc == '' OR 'A' 
TempAltLoc = {TargetModel.altLoc};
IndexAltLoc = find(strcmp(TempAltLoc, '') + strcmp(TempAltLoc, 'A'));

% Target atoms in Target chain
TempIndexAtominChain = intersect(intersect(IndexTargetAtom, IndexTargetChain), IndexAltLoc);
TempTargetAtominChain = TargetModel(TempIndexAtominChain);

% find Target atoms in segment
TempResSeq = [TempTargetAtominChain.resSeq];
IndexTargetAtominSegment = (TempResSeq >= PDB.segment(1) & TempResSeq <= PDB.segment(2));

% specified Target atoms
TargetAtominSegment = TempTargetAtominChain(IndexTargetAtominSegment);
 

%% Remark and Terminal
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


%% store fields to template
template.Remark999 = RemarkString;
template.Model.Atom = TargetAtominSegment;
template.Model.Terminal = EmptyTerminal;


end

