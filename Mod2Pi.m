function Y = Mod2Pi(X,AlgorithmType)
% MOD2PI 
% mod X by 2*pi into interval: (-pi,pi]
if nargin < 2
    AlgorithmType = 0;
end

Y = zeros(size(X));

switch AlgorithmType
    case 0 % using vectorization and mod()
        X = X(:);
        tempX = mod(X, 2*pi);
        tempX = tempX - 2*pi*(tempX>pi);
        Y = reshape(tempX, size(Y));
    case 1 % using matlab function mod()
        X = X(:);
        for i = 1:length(X)
            tempX = mod(X(i), 2*pi);
            if tempX > pi
                Y(i) = tempX - 2*pi;
            else
                Y(i) = tempX;
            end
        end
    case 2 % using code from C
        X = X(:);
        for i = 1:length(X)
            if abs(X(i)) > pi
                Y(i) = X(i) / (2*pi);        
                if Y(i) > 0
                    Y(i) = Y(i) - floor(Y(i));
                else
                    Y(i) = Y(i) - ceil(Y(i));
                end
    
                Y(i) = Y(i)*2*pi;
        
                if Y(i) > pi
                    Y(i) = Y(i) - 2*pi;
                end
        
                if Y(i) < -pi
                    Y(i) = Y(i) + 2*pi;
                end
            else
                Y(i) = X(i);
            end
        end
end

end

