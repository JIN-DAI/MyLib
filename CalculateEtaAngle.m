function EtaAngle = CalculateEtaAngle(CACoords, CBCoords)
%% CALCULATEETAANGLE
% Description: calculate Eta angles with CA and CB coordinates
%      Output: 
%       Input: 
% Author: J.Dai
% Created Date: 2016.03.21
% Last Modified Date: 2016.03.21


%% Check arguments
if size(CACoords, 2) ~= 3
    CACoords = CACoords';
    if size(CACoords, 2) ~= 3
        fprintf('ERROR: argument''s dimension should be Nx3!\n');
    end
end

if size(CBCoords, 2) ~= 3
    CBCoords = CBCoords';
    if size(CBCoords, 2) ~= 3
        fprintf('ERROR: argument''s dimension should be Nx3!\n');
    end
end


%% Calculate Eta Angles by definition

% initialize EtaAngle vector; row -> residue
EtaAngle = ones(size(CACoords, 1), 1);

% calculate angles and vectors from coordinates
switch 1
    case 1
        [Theta, Phi, vn, T, N, B] = angles(CACoords);
        if size(T, 2) ~= 3
            T = T';
        end
    case 2
        % calculate tangent vectors and bond length
        T = diff(CACoords);
        T = T./repmat(sqrt(diag(T*T')), 1, 3);% normalization
        T = [T [nan;nan;nan]];
end

% unit vectors pointing from C_Alpha to C_Beta; Vector U
BetaU = CBCoords - CACoords;
BetaU = BetaU./sqrt(diag(BetaU*BetaU')*ones(1,3));
% unit vectors of U_i's projection on the plane perpendicular to T_i; Vector V
BetaV = BetaU - (diag(BetaU*T')*ones(1,3)).*T;
BetaV = BetaV./sqrt(diag(BetaV*BetaV')*ones(1,3));
% unit vectors of U_(i+1)'s projection on the plane perpendicular to T_i; Vector W
BetaW = BetaU(2:end,:) - (diag(BetaU(2:end,:)*T(1:end-1,:)')*ones(1,3)).*T(1:end-1,:);
BetaW = BetaW./sqrt(diag(BetaW*BetaW')*ones(1,3));
BetaW = [BetaW; nan nan nan];

% angle from V to W, anti-clockwise direction is positive; Eta Angle
for iRow = 1:size(CACoords, 1)
    EtaAngle(iRow) = acos(dot(BetaV(iRow,:), BetaW(iRow,:)));
    EtaAngle(iRow) = -sign(dot(T(iRow,:), cross(BetaV(iRow,:), BetaW(iRow,:)))) * EtaAngle(iRow);
end



end

