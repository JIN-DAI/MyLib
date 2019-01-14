function [Psi, Omega, Phi] = CalculateDihedralAnglesSingleChain(Atoms)
%% CALCULATEDIHEDRALANGLESSINGLECHAIN
% Description: calculate dihedral angles (Psi, Omega, Phi) along backbone.
% Author: J.Dai
% Created Date: 2017.06.21
% Last Modified Date: 2017.06.21


%%
% list of residue sequence number
ResSeqList = unique([Atoms.resSeq]);
% number of total residues
TotalResN = numel(ResSeqList);

% find AtomsName and Coords
AtomList = {'N', 'CA', 'C', 'O'};
AtomIndex = nan(numel(AtomList), numel(Atoms));
for iAtom = 1:numel(AtomList)
    I = strcmp({Atoms.AtomName}, AtomList{iAtom});
    AtomIndex(iAtom,:) = I;
    AtomCoords.(AtomList{iAtom}) = [[Atoms(I).X]', [Atoms(I).Y]', [Atoms(I).Z]'];
end

% is cycle
isCycle = norm(AtomCoords.CA(1,:)-AtomCoords.CA(end,:)) < 4.0;

% dihedral list
% Psi(i): N(i)-CA(i)-C(i)-N(i+1); 1,2,...,N-2,N-1
% Omega(i): CA(i)-C(i)-N(i+1)-CA(i+1); 1,2,...,N-2,N-1
% Phi(i): C(i-1)-N(i)-CA(i)-C(i); 2,3,...,N-1,N
DihedralList.AngleName = {'Psi'; 'Omega'; 'Phi'};
DihedralList.AngleValue = repmat({nan(TotalResN,1)}, 3, 1);
DihedralList.Atom = {'N', 'CA', 'C', 'N'; ...   % Psi
                     'CA', 'C', 'N', 'CA'; ...  % Omega
                     'C', 'N', 'CA', 'C'};      % Phi
DihedralList.Shift = {0, 0, 0, 1; ...   % Psi
                      0, 0, 1, 1; ...   % Omega
                      -1, 0, 0, 0};     % Phi

% calculate dihedral angles
for iR = 1:size(DihedralList.Atom,1)
    Coords = cell(1, size(DihedralList.Atom,2));
    
    for iC = 1:size(DihedralList.Atom,2)
         Coods_org = AtomCoords.(DihedralList.Atom{iR,iC});
                 
         NAtom = size(Coods_org, 1);
         I = [(1:NAtom)', (1:NAtom)'+DihedralList.Shift{iR,iC}];
         InRange = (I(:,2) >= 1) & (I(:,2) <= NAtom);
         if any(~InRange)
             if isCycle
                 I(I(:,2)>NAtom,2) = I(I(:,2)>NAtom,2) - NAtom;
                 I(I(:,2)<1,2) = I(I(:,2)<1,2) + NAtom;
             else
                 I(~InRange,2) = nan;
             end
         end
         I = I(~isnan(I(:,2)),:);
         
         Coords{iC} = nan(size(Coods_org));
         Coords{iC}(I(:,1),:) = Coods_org(I(:,2),:);
    end
    DihedralList.AngleValue{iR}(:) = localCalDihedral(Coords);
end

Psi = DihedralList.AngleValue{1};
Omega = DihedralList.AngleValue{2};
Phi = DihedralList.AngleValue{3};

end

% calculate dihedral angles
function Dihedral = localCalDihedral(Coords)
    Va = Coords{2}-Coords{1}; % 1->2
    Vb = Coords{3}-Coords{2}; % 2->3
    Vc = Coords{4}-Coords{3}; % 3->4
    
    Va = normalizeByRow(Va); % normalization
    Vb = normalizeByRow(Vb); % normalization
    Vc = normalizeByRow(Vc); % normalization
    
    % unit component of a perpendicular to b
    Vavb = Va - repmat(diag(Va*Vb'),1,3).*Vb;
    Vavb = normalizeByRow(Vavb);
    % unit component of c perpendicular to b
    Vcvb = Vc - repmat(diag(Vc*Vb'),1,3).*Vb;
    Vcvb = normalizeByRow(Vcvb);
    
    % cross product of -Vavb and Vcvb
    a_cross_c = [-(Vavb(:,2).*Vcvb(:,3) - Vavb(:,3).*Vcvb(:,2)), ...
                 -(Vavb(:,3).*Vcvb(:,1) - Vavb(:,1).*Vcvb(:,3)), ...
                 -(Vavb(:,1).*Vcvb(:,2) - Vavb(:,2).*Vcvb(:,1))];
    
    % sign determined by the inner product of Vb and a_cross_c
    SIGN = sign(diag(Vb*a_cross_c'));
    
    % dihedral angle according to IUPAC
    % refer link: http://www.proteinstructures.com/Structure/Structure/Ramachandran-plot.html
    Dihedral = SIGN.*acos(diag(-Vavb*Vcvb'));
end

% normalize along row
function V = normalizeByRow(V)
    V = V./repmat(sqrt(diag(V*V')),1,3);
end





