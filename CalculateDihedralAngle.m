function Dihedral = CalculateDihedralAngle(R1,R2,R3,R4)
%% CALCULATEDIHEDRALANGLE 
% Description: calculate dihedral angle of R1-R2-R3-R4 about axis R2-R3
% Author: J.Dai
% Created Date: 2017.10.19
% Last Modified Date: 2017.10.19


%%
% ensure the shape of coordinates is Nx3
R1 = CheckCoordsDim(R1);
R2 = CheckCoordsDim(R2);
R3 = CheckCoordsDim(R3);
R4 = CheckCoordsDim(R4);

% normalized directional vector
Va = normalizeByRow(R2-R1); % 1->2
Vb = normalizeByRow(R3-R2); % 2->3 as axis
Vc = normalizeByRow(R4-R3); % 3->4

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


%% normalize along row
function V = normalizeByRow(V)
    V = V./repmat(sqrt(diag(V*V')),1,3);
end

