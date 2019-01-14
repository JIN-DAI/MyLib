function Pool = startParpool(PoolNum)
% start parpool
Pool = gcp('nocreate');

if isempty(Pool)
    if nargin < 1
        switch computer('arch')
            case {'win64', 'win32'}
                PoolNum = 4;
            case 'glnxa64'
                PoolNum = 4;
            case 'maci64'
                PoolNum = 8;
            otherwise
                PoolNum = 1;
        end
    end
    Pool = parpool('local', PoolNum);
end

end

