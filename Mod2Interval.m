function Y = Mod2Interval(X,Interval,AlgorithmType)
% MOD2INTERVAL 
% mod X by 2*Interval into interval: (-Interval,Interval]
if nargin < 3
    AlgorithmType = 0;
end

if nargin < 2
    Interval = pi;
end

Y = zeros(size(X));

switch AlgorithmType
    case 0 % using vectorization and mod()
        X = X(:);
        tempX = mod(X, 2*Interval);
        tempX = tempX - 2*Interval*(tempX>Interval);
        Y = reshape(tempX, size(Y));
    case 1 % using matlab function mod()
        X = X(:);
        for i = 1:length(X)
            tempX = mod(X(i), 2*Interval);
            if tempX > Interval
                Y(i) = tempX - 2*Interval;
            else
                Y(i) = tempX;
            end
        end
    case 2 % using code from C
        X = X(:);
        for i = 1:length(X)
            if abs(X(i)) > Interval
                Y(i) = X(i) / (2*Interval);        
                if Y(i) > 0
                    Y(i) = Y(i) - floor(Y(i));
                else
                    Y(i) = Y(i) - ceil(Y(i));
                end
    
                Y(i) = Y(i)*2*Interval;
        
                if Y(i) > Interval
                    Y(i) = Y(i) - 2*Interval;
                end
        
                if Y(i) < -Interval
                    Y(i) = Y(i) + 2*Interval;
                end
            else
                Y(i) = X(i);
            end
        end
end

end

