function startJmol(scriptname)
%%STARTJMOL
% Description: start Jmol app in matlab environment
% Author: J.Dai
% Created Date: 2017.04.25
% Last Modified Date: 2017.06.19


%% Environment Settings
% Check Operating System Version
SYSTEM_VERSION = computer('arch');


%% Jmol Parameters
% jmol.jar
if ~strncmp(SYSTEM_VERSION, 'win', 3)
    % for UNIX-like system
    Jmol.jar = fullfile('..', 'MyResource', 'Jmol', 'startjmol.sh'); %startjmol.sh @MyResource
else
    % for windows
    Jmol.jar = fullfile('F:', 'MyProgram', 'MyMatlab', 'MyResource', 'Jmol', 'Jmol.jar'); % Jmol.jar @MyResource
end

if ~exist(Jmol.jar, 'file')
    fprintf('ERROR: can not find Jmol.jar at specific path!\n');
    return;
end


%% run Jmol with script in the background
if ~strncmp(SYSTEM_VERSION, 'win', 3)
    % run Jmol in UNIX-like system
    if nargin < 1 || isempty(scriptname)
        system([Jmol.jar ' &']);
    else
        system([Jmol.jar ' ' scriptname ' &']);
    end
else
    % run Jmol in windows
    if nargin < 1 || isempty(scriptname)
        system([Jmol.jar ' &']);
    else
        system([Jmol.jar ' -s ' scriptname ' &']);
    end
end


end

