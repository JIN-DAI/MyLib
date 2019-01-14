function runPulchra(FileName, Option, Pulchra)
%% RUNPULCHRA

%%
if nargin < 3 || isempty(Pulchra)
    % pulchra304 @MyResource
    Pulchra.home = fullfile('F:', 'MyProgram', 'MyMatlab', 'MyResource', 'pulchra304');
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

