function Coords = CheckCoordsDim(Coords, NCol)
if nargin < 2
    NCol = 3;
end

if size(Coords,2) ~= NCol
    Coords = Coords';
end

end

