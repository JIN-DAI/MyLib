function R_rescale = rescale(R_origin, delta)
%% RESCALE
% uniformly rescale

[theta,phi,vn]=anglesO(R_origin);

if abs(vn-delta) > eps
    if numel(delta) ~= numel(vn)
        delta = repmat(delta(1), size(vn));
    end
    R_rescale = curve3d(theta,phi,delta)';
else
    R_rescale = R_origin;
end

end

