function vecX = CrossMatrixLeft(vec)
%% CrossMatrixLeft
% cross(a,b) = CrossMatrixLeft(a)*b where b is a column vector.

%%
if size(vec, 2) ~= 1
    vec = vec';
end
if size(vec, 1) ~= 3
    error('The number of raws must be three!');
end

%%
vecX = [0 -vec(3) vec(2);
        vec(3) 0 -vec(1);
        -vec(2) vec(1) 0];

end

