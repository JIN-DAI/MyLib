function CrossPt = linecross(line1, line2)
%% LINECROSS
% find cross point of line1 and line2
% line1 and line2 are represented by 2x3 matrix, each row corresponds to one point
% https://blog.csdn.net/hunter_wwq/article/details/41044179

%%
V1 = line1(2,:)-line1(1,:);
V1 = V1./norm(V1);
R1 = line1(1,:);

V2 = line2(2,:)-line2(1,:);
V2 = V2./norm(V2);
R2 = line2(1,:);

if norm(cross(V1,V2)) < eps || abs(dot(R2-R1, cross(V1, V2))) > 100*eps
    CrossPt = [];
end

T1 = dot(cross(R1-R2, V2), cross(V2,V1))/norm(cross(V2,V1))^2;
CrossPt = R1 + T1*V1;


end

