function Angle = CalculateAngleMatrix(Coords)
%% CALCULATEANGLEMATRIX
% calculate the orientation of Tj corresponding to Ti for element ij
% Assuming T is normalized, frame is constructed as
%   \hat{x} = Ti
%   \hat{z} = cross(Ti,Tj)/norm(cross(Ti,Tj))
%   \hat{y} = cross(\hat{z}, \hat{x})
% So the components of Tj in frame is
%   X = dot(Tj,\hat{x}) = dot(Tj, Ti)
%   Y = dot(Tj,\hat{y}) = {1-dot(Tj,Ti)^2}/norm(cross(Ti,Tj))
%   Z = dot(Tj,\hat{z}) = 0
% Thus angle is caluclated by atan2(Y,X)

%%
% default size of Coords: n x 3, n >= 3
if size(Coords, 2) ~= 3
    Coords = Coords'; 
end

% cutoff length for zero tangent vector
Lt_cutoof = 1e-10;
% tangent vector
T = diff(Coords,1,1);
T = [T; Coords(1,:)-Coords(end,:)];
% length of tangent vector
vn = sqrt(diag(T*T'));
% normalization
T = T./repmat(vn, 1, 3);
if any(abs(vn)<Lt_cutoof)
    T(abs(vn)<Lt_cutoof, :) = 0;
end

%%
CrossCutoff = 1e-12;
MatX = T*T';
MatY = nan(size(MatX));
for i = 1:size(T,1)
    for j = 1:size(T,1)
        CrossIJ = norm(cross(T(i,:), T(j,:)));
        if CrossIJ < CrossCutoff
            MatY(i,j) = 0;
        else
            MatY(i,j) = (1-MatX(i,j)^2)/CrossIJ;
        end
    end
end
Angle = atan2(MatY, MatX);



end

