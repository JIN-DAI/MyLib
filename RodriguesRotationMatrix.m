function RotMat = RodriguesRotationMatrix(k,theta)
%% RODRIGUESROTATIONMATRIX 
% Description: create the Rodrigues' rotation matrix specified by rotation axis k and angle theta (by right hand rule).

%%
K = [0, -k(3), k(2);
     k(3), 0, -k(1);
     -k(2), k(1), 0];

RotMat = eye(3) + sin(theta)*K + (1-cos(theta))*K*K;

end

