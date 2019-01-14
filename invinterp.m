function [x0,y0]=invinterp(x,y,y0) 
%% INVINTERP
% copied from web:http://blog.csdn.net/winbobob/article/details/39118513
% Description: run basic analysis on Calpha coordinates
% Author: J.Dai
% Created Date: 2017.06.18
% Last Modified Date: 2017.06.24


%%
x = x(:);
y = y(:);

n = numel(y);

if y0<min(y) || y0>max(y)
    x0 = [];
    y0 = [];
else
    % index of the below part of y
    below = y<y0;
    % index of the above part of y
    above = y>=y0;
    % the index whose previous value on the otherside of y0
    kth = (below(1:n-1)&above(2:n)) | (above(1:n-1)&below(2:n));
    % the next index of kth
    kp1 = [false; kth];
    % ratio of the intersectio point along y-axis
    alpha = (y0-y(kth))./(y(kp1)-y(kth));
    % use the above ratio to linearly compute its x-value
    x0 = alpha.*(x(kp1)-x(kth))+x(kth);
    % fill the y0 with the same size as x0
    y0 = repmat(y0,size(x0));
end


end

