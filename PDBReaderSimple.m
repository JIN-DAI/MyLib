function Coords = PDBReaderSimple(filename)
%PDBREADERSIMPLE Summary of this function goes here
%   Detailed explanation goes here

% Latest updated: 2016.11.09

%%
fid = fopen(filename, 'r');

if fid == -1
    fprintf('ERROR: unable to open file %s!\n', filename);
    return;
end

theLines = textscan(fid, '%s', 'delimiter', '\n');
theLines = theLines{1};
fclose(fid);

%%
Coords = [];

if false
    numLines = numel(theLines);
    lineCounter = 1;

    while lineCounter <= numLines
        tline = theLines{lineCounter};
        lineCounter = lineCounter + 1;
        
        % for end of file recognition
        if ~ischar(tline)
            break;
        end
        % omit the empty lines to avoid error of invalid matrix index
        if isempty(tline)
            continue;
        end
        
        % find line start with 'ATOM'
        if strncmp(tline, 'ATOM', length('ATOM'))
            Coords = [Coords; str2num(tline(31:38)) str2num(tline(39:46)) str2num(tline(47:54))];
        end
    end
else
    AtomLines = regexp(theLines, '^ATOM '); % find lines started with 'ATOM '
    subLinesMat = cell2mat(theLines(~cellfun(@isempty, AtomLines))); % abstract lines and transfer it to matrix
    Coords = [str2num(subLinesMat(:,31:38)) str2num(subLinesMat(:,39:46)) str2num(subLinesMat(:,47:54))]; % get coordinates
end


end

