function [TotalSA, ResSA] = CalculateSAbyDSSP(InFile, OutFile, Options, Executable)
%% CalculateSAbyDSSP.m
% Script Description: Calculate solvent accessibility "SA" from InputFile
%                     by dssp using Options and output result to OutputFile.
% Author: J.Dai
% Created Date: 2016.09.10
% Last Modified Date: 2016.09.13


%% default arguments
% the absolute address of the dssp excutable file
if nargin < 4 || isempty(Executable)
    Executable = 'F:\Dropbox\MyMatlab\MyResource\dssp\dssp-2.0.4-win32.exe';
end

% the options to run dssp
if nargin < 3 || isempty(Options)
    Options = ' ';
end

% path and filename of output
if nargin < 2 || isempty(OutFile)
    OutFile = fullfile('.', 'tempDSSPout.dssp');
end

% path and filename of input
if nargin < 1 || ~exist(InFile, 'file')
    fprintf('ERROR: source pdb file does not exist!\n');
    return;
end


%% Run dssp for input file
% start timer
tic;
% string of command
Cmd = [Executable ' ' Options ' ' InFile ' ' OutFile];
% run command with system
[Status, Cmdout] = system(Cmd);
% stop timer and record timecost
TimeCost = toc;


%% Load dssp outfile
% -open file
Fid = fopen(OutFile, 'r');
if Fid == -1
    fprintf('ERROR: unable to read file %s!\n', OutFile);
    return;
end
% -load file
Lines.Total = textscan(Fid,'%s','delimiter','\n');
Lines.Total = Lines.Total{1};
% -close file
fclose(Fid);


%% Read outfile to extract information of TotalSA and ResSA
% line marker for total solvent asseccibility
LineMarker.TotalSA = 'ACCESSIBLE SURFACE OF PROTEIN';
% extract total solvent accessibility
% -find the line with TotalSALineMarker
TotalSALine = Lines.Total{~cellfun(@isempty, strfind(Lines.Total, LineMarker.TotalSA))};
% -extract TotalSA from line
TotalSA = str2double(TotalSALine(1:strfind(TotalSALine, LineMarker.TotalSA)-1));


% title line marker for total solvent asseccibility
LineMarker.ResSA = ' ACC ';
% extract solvent accessibility on each residue
% -find the index of the title line
LineMarker.ResSAIndex = find(~cellfun(@isempty, strfind(Lines.Total, LineMarker.ResSA)));
% -put the space back to each following line, 
% because each line in the file has 136 characters.

% lines of ATOM
Lines.Rest = Lines.Total(LineMarker.ResSAIndex+1:end);

% length of lines
LineLength.CharN = 136;
LineLength.LineN = numel(Lines.Rest);
LineLength.Rest = cell2mat(cellfun(@length, Lines.Rest, 'UniformOutput', false));
LineLength.Diff = LineLength.CharN - LineLength.Rest;
LineLength.ColN = mat2cell(LineLength.Diff, ones(LineLength.LineN,1));
LineLength.RowN = mat2cell(ones(LineLength.LineN,1), ones(LineLength.LineN,1));

spaceCell = mat2cell(repmat(' ', LineLength.LineN, 1), ones(LineLength.LineN,1));
spaceCell = cellfun(@repmat, spaceCell, LineLength.RowN, LineLength.ColN, 'UniformOutput', false);

Lines.RestNew = strcat(spaceCell, Lines.Rest);
Lines.RestMat = cell2mat(Lines.RestNew);

% -extract ResSA from the new lines
ResSA = str2num(Lines.RestMat(:, 35:38));


end

