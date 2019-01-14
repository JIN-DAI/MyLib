function Rg = CalculateRadiusOfGyration(Coords, AlgrithomType)
%CALCULATERADIUSOFGYRATION Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    AlgrithomType = 1;
end

if size(Coords,2) ~= 3
    Coords = Coords';
end

RowInd = ~any(isnan(Coords),2); % index of non-nan rows
RowNum = sum(RowInd); % number of rows

Coords = Coords(RowInd, :);

switch AlgrithomType
    case 1
        Rc = mean(Coords); % coordinates of mass center
        Ric = [Coords(:,1) - Rc(1), Coords(:,2) - Rc(2), Coords(:,3) - Rc(3)]; % coordinates refer to mass center
        Rg = sqrt(mean(diag(Ric*Ric'))); 
    case 2
        Mij = Coords*Coords'; % r_i * r_j
        Rg = sqrt(mean(diag(Mij))-sum(sum(Mij))/(RowNum*RowNum));
end


end

