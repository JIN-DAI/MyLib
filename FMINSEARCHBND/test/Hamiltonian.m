function H = Hamiltonian(angles)
%% HAMILTONIAN
% angles = [phi_1, theta_1, phi_2, theta_2, ..., phi_N, theta_N];

N = numel(angles)/2;
H = 0;

for i = 1:(N-1)
    H = H + ...
        cos(angles(2*i-1))*sin(angles(2*i)) * cos(angles(2*i+1))*sin(angles(2*i+2)) + ...
        sin(angles(2*i-1))*sin(angles(2*i)) * sin(angles(2*i+1))*sin(angles(2*i+2)) + ...
        cos(angles(2*i)) * cos(angles(2*i+2));
end

end

