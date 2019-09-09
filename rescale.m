function R_rescale = rescale(R_origin, delta)
%RESCALE Summary of this function goes here
%   Detailed explanation goes here

[theta,phi,vn]=anglesO(R_origin);

if abs(vn-delta) > eps
    R_rescale = curve3d(theta,phi,delta)';
else
    R_rescale = R_origin;
end

end

