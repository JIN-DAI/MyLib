function [AngleCell, StepArray] = AngleReaderSimple(filename)
%% default settings
MAX_STEP = 1000;
AngleCell = [];
StepArray = [];

%% open file and read lines in file
fid = fopen(filename, 'r');

if fid == -1
    fprintf('ERROR: unable to open file %s', filename);
    return;
end

theLines = textscan(fid, '%s', 'delimiter', '\n');
theLines = theLines{1};
fclose(fid);

%% store angle information into AngleCell and StepArray
StepCounter = 0;
AngleCell = cell(MAX_STEP,1);
StepArray = zeros(MAX_STEP,1);

numLines = numel(theLines);
lineCounter = 1;

while lineCounter <= numLines
    % read one line
    tline = theLines{lineCounter};
    % increase line counter
    lineCounter = lineCounter + 1;
    
    % for end of file recognition
    if ~ischar(tline)
        break;
    end
    
    % omit empty lines
    if isempty(tline)
        continue;
    end
    
    % find line start with 'Step:' and line containing angles
    KeyWord = 'Step:';
    if strncmp(tline, KeyWord, length(KeyWord))
        % store TempAngle into AngleCell when StepCounter is non-zero and TempAngle is non-empty
        if StepCounter ~= 0 && ~isempty(TempAngle)
            AngleCell{StepCounter} = TempAngle;
        end
        % increase step counter
        StepCounter = StepCounter + 1;
        % record step
        StepArray(StepCounter) = str2double(tline(length(KeyWord)+1:end));
        % initialize TempAngle
        TempAngle = [];
    else
        TempAngle = [TempAngle; str2num(tline)];
    end
    
end
% store the last TempAngle into AngleCell
if ~isempty(TempAngle)
    AngleCell{StepCounter} = TempAngle;
end

% trim AngleCell and StepArray with StepCounter
AngleCell = AngleCell(1:StepCounter);
StepArray = StepArray(1:StepCounter);


end

