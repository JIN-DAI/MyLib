function [a, b] = swap(a, b)
%SWAP Summary of this function goes here
%   Detailed explanation goes here
b = a + b; % [a,b]->[a,a+b]
a = b - a; % [a,a+b]->[b,a+b]
b = b - a; % [b,a+b]->[b,a]

end

