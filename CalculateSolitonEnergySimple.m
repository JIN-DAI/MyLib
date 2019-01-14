function Energy = CalculateSolitonEnergySimple(Kappa, Tau, SolPars)
%% CalculateSolitonEnergySimple
% Function Description:
% Author: J.Dai
% Created Date: 2015.11.23
% Last Modified Date: 2015.11.25

% Input:
% -Kappa: curvature angles
% -Tau: torsion angles
% -SolPars: energy parameters, {c,m,b,d,e,q}
% Output:
% -Energy: total energy

%%
% energy parameters
BondStrength = 1;
c = [SolPars.c]';
m = [SolPars.m]';
b = [SolPars.b]';
d = [SolPars.d]';
e = [SolPars.e]';
q = [SolPars.q]';

% --- Pure Curvature Part ---
EnCurvature = 0;
% BondStrength*(k_(i+1)-k_i)^2
EnCurvature = EnCurvature + BondStrength*sum((Kappa(1:end-1)-Kappa(2:end)).^2);
% c*(k_i^2-m^2)^2
EnCurvature = EnCurvature + sum(c.*(Kappa.^2-m.^2).^2);

% --- Pure Torsion Part ---
% d*t_i + e*t_i^2
EnTorsion = sum(d.*Tau) + sum(e.*Tau.^2);

% Kmid_(i+1) = (k_i+k_(i+1))/2
Kmid = (Kappa(1:end-1)+Kappa(2:end))/2;
% Kmid2 = Kimd^2
Kmid2 = Kmid.^2;

% --- Curvature&Torsion Coupling Part ---
EnCoupling = 0;
% b*k_i^2*t_i^2
EnCoupling = EnCoupling + sum(b(2:end).*Kmid2.*Tau(2:end).^2);
% q*k_i^2*t_i
EnCoupling = EnCoupling + sum(q(2:end).*Kmid2.*Tau(2:end));

% --- Total Soliton Energy ---
Energy = EnCurvature + EnTorsion + EnCoupling;


end

