function PlotStructureInJmol(filename, scriptname, CmapStyle)
%%PLOTSTRUCTUREINJMOL 
% Description: load multiple pdb files into Jmol and color them by
% specified colormap, then display them in Jmol

%% Environment Settings
% Check Operating System Version
SYSTEM_VERSION = computer('arch');
% File Separator in corresponding OS
FS = filesep;
% Current Path
PWD = pwd;

if nargin < 3
    % Colormap Style
    CmapStyle = 'jet';
end
% colormap
Cmap = eval(sprintf('%s(%d)', CmapStyle, numel(filename)));

%% Jmol Parameters
% jmol.jar
if ~strncmp(SYSTEM_VERSION, 'win', 3)
    % for UNIX-like system
    Jmol.jar = ['..' FS 'MyResource' FS 'Jmol' FS 'startjmol.sh']; %startjmol.sh @MyResource
else
    % for windows
    Jmol.jar = ['..' FS 'MyResource' FS 'Jmol' FS 'Jmol.jar']; % Jmol.jar @MyResource
end

% JmolScript path
if nargin < 2 || isempty(scriptname)
    Jmol.script = ['.' FS 'TempJmolScript.spt'];
else
    Jmol.script = ['.' FS scriptname];
end

%% Check whether filename is cell
if ~iscell(filename)
    filename = {filename};
end

%% write jmol script file for visualization
% open script file
Script.fid = fopen(Jmol.script, 'w');
if Script.fid == -1
    fprintf('ERROR: unable to access script file %s\n', Jmol.script);
    return;
end

% script content
fprintf(Script.fid, 'load file %s\n\n', [PWD FS filename{1}]);
fprintf(Script.fid, 'select 1.0;\ncolor [%d %d %d];\n\n', Cmap(1,1), Cmap(1,2), Cmap(1,3));
for i = 2:numel(filename)
    % script content
    fprintf(Script.fid, 'load append file %s\n\n', [PWD FS filename{i}]);
    fprintf(Script.fid, 'select %d.0;\ncolor [%d %d %d];\n\n', i, Cmap(i,1), Cmap(i,2), Cmap(i,3));
end

fprintf(Script.fid, 'background white;\nselect all;\nframe all;\nwireframe off;\nspacefill off;\n\n');
fprintf(Script.fid, 'backbone off;\ncartoon off;\ntrace 0.3;\n\n');

% close script file
fclose(Script.fid);

%% run Jmol with script in the background
if ~strncmp(SYSTEM_VERSION, 'win', 3)
    % run Jmol in UNIX-like system
    system([Jmol.jar ' ' Jmol.script ' &']);
else
    % run Jmol in windows
    system([Jmol.jar ' -s ' Jmol.script ' &']);
end

end

