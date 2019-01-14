function CAAtom = CreateCAAtom(Coords, resName)
%% CREATECAATOM
% Description: create a struct for CA atom of one model which are related to pdbread/pdbwrite functions.
% Author: J.Dai
% Latest Modified Date: 2017.06.16


%%
% check the dimension of coordinates matrix
if size(Coords,2) ~= 3
    Coords = Coords';
end
[N_Atom, N_Coords] = size(Coords);
if N_Coords ~= 3
    fprintf('ERROR: the coordinates matrix should have the shape as nx3 or 3xn!\n');
    CAAtom = [];
    return;
end

% check the size of resName
if nargin < 2 || isempty(resName)
    resName = repmat({'ALA'}, N_Atom, 1);
end

if numel(resName) ~= N_Atom
    fprintf('ERROR: the residue names should have the number as atoms!\n');
    CAAtom = [];
    return;
end


%%
AtomSerNo = num2cell((1:N_Atom)');
AtomName = 'CA';
altLoc = '';
chainID = 'A';
resSeq = num2cell((1:N_Atom)');
iCode = '';
X = num2cell(Coords(:,1));
Y = num2cell(Coords(:,2));
Z = num2cell(Coords(:,3));
occupancy = 1;
tempFactor = 10;
segID = '    ';
element = 'C';
charge = '  ';
AtomNameStruct.chemSymbol = 'C';
AtomNameStruct.remoteInd = 'A';
AtomNameStruct.branch = '';


%%
CAAtom = struct('AtomSerNo',      AtomSerNo, ...
                'AtomName',       AtomName, ...
                'altLoc',         altLoc, ...
                'resName',        resName, ...
                'chainID',        chainID, ...
                'resSeq',         resSeq, ...
                'iCode',          iCode, ...
                'X',              X, ...
                'Y',              Y, ...
                'Z',              Z, ...
                'occupancy',      occupancy, ...
                'tempFactor',     tempFactor, ...
                'segID',          segID, ...
                'element',        element, ...
                'charge',         charge, ...
                'AtomNameStruct', AtomNameStruct);



end

