function runPulchra(FileName, Option, Pulchra)
%% RUNPULCHRA

%%
if nargin < 3 || isempty(Pulchra)
    workDir = {fullfile('D:', 'Programs', 'MatlabCodes'), fullfile('F:', 'MyProgram', 'MyMatlab')};
    indexDir = cellfun(@(x) exist(x, 'dir')~=0, workDir);
    if sum(indexDir) < 1
        error('Work dir does not exist!');
    elseif sum(indexDir) > 1
        error('Multiple work dirs exist!');
    end
    % pulchra304 @MyResource
    Pulchra.home = fullfile(workDir{indexDir}, 'MyResource', 'pulchra304');
    % --executable file's location
    Pulchra.executable = fullfile(Pulchra.home, 'bin');
    switch computer('arch')
        case 'maci64' % for MacOSX system
            Pulchra.executable = fullfile(Pulchra.executable, 'osx', 'pulchra');
        case 'glnxa64' % for linux system
            Pulchra.executable = fullfile(Pulchra.executable, 'linux', 'pulchra');
        case {'win32', 'win64'} % for windows
            Pulchra.executable = fullfile(Pulchra.executable, 'win32', 'pulchra.exe');
    end
end

if nargin < 2 || isempty(Option)
    Option = '-v';
end

% run Pulchra
TempSystem = [Pulchra.executable ' ' Option ' ' FileName];
system(TempSystem);

end

