function CMean = CircularMean(DataMat)
%CIRCULARMEAN Summary of this function goes here
%   Detailed explanation goes here

% refer to https://en.wikipedia.org/wiki/Mean_of_circular_quantities

if size(DataMat,2) > 1
    CMean = atan2(sum(sin(DataMat), 2), sum(cos(DataMat), 2));
else
    CMean = atan2(sum(sin(DataMat)), sum(cos(DataMat)));
end

end

