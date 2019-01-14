function parameterStruct = ReadParameters(filename)
%% READPARAMETERS SUMMARY
% Description: Read parameters xml file of CurveUI+ into struct-{Globals, Soliton}
% Author: Jin Dai
% Date: 2014.07.03

%% check whether file is empty
xmlRootStruct = parseXML(filename);
if isempty(xmlRootStruct)
    fprintf('ERROR: file %s is empty!\n', filename);
    return
end

%% check root node tag name
ROOT_NODE_NAME = 'Settings';
% check root node tag name
if ~strcmp(xmlRootStruct.Name, ROOT_NODE_NAME)
    fprintf('ERROR: Root node tag name should be ''%s''!\n', ROOT_NODE_NAME);
    return;
end
% child nodes of root node which should be 'Globals' and 'Soliton'
xmlChildStruct = xmlRootStruct.Children;
% parameterStruct corresponding to root node
parameterStruct = [];

%% find nodes with tag name as 'Globals'
% target tag name: 'Globals'
TARGET_TAG = 'Globals';
% index of nodes with tag name as 'Globals'
TARGET_INDEX = find(strcmp({xmlChildStruct.Name}, TARGET_TAG));
% check the existence of 'Globals' node
if isempty(TARGET_INDEX)
    fprintf('ERROR: No element with tag name as ''%s'' in root node!\n', TARGET_TAG);
    return;
end
% field-'Globals' corresponding to node-'Globals'
parameterStruct.Globals = [];

% target child node tag names in 'Globals'
TARGET_CHILD = {'Parameter', 'CalculateTau'};

% nodes with tag name as 'Globals'
for i = 1:length(TARGET_INDEX)
    % i-th Globals' child nodes
    tempChild = xmlChildStruct(TARGET_INDEX(i)).Children;
    % child nodes' tag names
    tempName = {tempChild.Name};
    
    % nodes with tag name as 'Parameter'
    % nodes' index in Globals
    tempIndex = find(strcmp(tempName, TARGET_CHILD{1}));
    % check the existence of 'Parameter' node
    if isempty(tempIndex)
        fprintf('ERROR: No element with tag name as ''%s'' in ''%s''!\n', TARGET_CHILD{1}, TARGET_TAG);
        return;
    end
    % read 'Parameter' nodes
    for j = 1:length(tempIndex)
        % j-th 'Parameter' node
        tempElement = tempChild(tempIndex(j));
        
        % 'Parameter' node's Attributes-(name)
        if strcmp(tempElement.Attributes.Name, 'name')
            % get the global variable's name from value
            tempField = tempElement.Attributes.Value;
            % create corresponding field in the struct
            parameterStruct.Globals.(tempField) = [];

            % child nodes of 'Parameter' node to descript the global variable's value and its changes
            % TagName->Start : variable's start value
            % TagName->Linear : variable's value changes from (start, startv) to (end, endv) linearly
            % TagName->Exponential : variable's value changes from (start, startv) to (end, endv) exponentially
            tempCounter = 0; % counter of Changes
            for k = 1:length(tempElement.Children)
                % k-th child node of 'Parameter' node
                tempEleChild = tempElement.Children(k);
                % child node's tag name
                tempEleName = tempEleChild.Name;
                
                switch tempEleName
                    case 'Start' % Attributes-(value)
                        parameterStruct.Globals.(tempField).Start = str2double(tempEleChild.Attributes.Value);
                    case {'Linear', 'Exponential'} % Attributes-(start, startv, end, endv)
                        % create field-'Changes' if tempCounter == 0
                        if tempCounter == 0 
                            parameterStruct.Globals.(tempField).Changes = [];
                        end
                        % increase tempCounter by 1
                        tempCounter = tempCounter + 1;
                        % Type of Changes: 'Linear' or 'Exponential'
                        parameterStruct.Globals.(tempField).Changes(tempCounter).Type = tempEleName;
                        % Value matrix of Changes to store the start point and end point
                        % -[ start startv ]
                        % -[ end   endv   ]
                        parameterStruct.Globals.(tempField).Changes(tempCounter).Value = nan(2,2);                       
                        for m = 1:length(tempEleChild.Attributes)
                            switch tempEleChild.Attributes(m).Name
                                case 'start' 
                                    tempRC = [1 1];
                                case 'startv'
                                    tempRC = [1 2];
                                case 'end'
                                    tempRC = [2 1];
                                case 'endv'
                                    tempRC = [2 2];
                                otherwise
                                    tempRC = [];
                            end % END SWITCH
                            parameterStruct.Globals.(tempField).Changes(tempCounter).Value(tempRC(1),tempRC(2)) = str2double(tempEleChild.Attributes(m).Value);
                        end % END FOR-m
                end % END SWITCH
            end % END FOR-k
        end % END IF
    end % END FOR-j
    
    % node with tag name as 'CalculateTau'
    % field name-'CalculateTau' in field-'Globals'
    tempField = TARGET_CHILD{2};
    % nodes' index in Globals
    tempIndex = find(strcmp(tempName, tempField));
    if isempty(tempIndex)
        % if node does not exist, default value of 'CalculateTau' is 0
        parameterStruct.Globals.(tempField) = 0;
    else % if node existes
        parameterStruct.Globals.(tempField) = str2double(tempChild(tempIndex).Attributes.Value);
    end
    
end % END FOR-i

%% find nodes with tag name as 'Soliton'
% target tag name: 'Soliton'
TARGET_TAG = 'Soliton';
% index of nodes with tag name as 'Soliton'
TARGET_INDEX = find(strcmp({xmlChildStruct.Name}, TARGET_TAG));
% check the existence of 'Soliton' node
if isempty(TARGET_INDEX)
    fprintf('ERROR: No element with tag name as ''%s'' in root node!\n', TARGET_TAG);
    return;
end
% field-'Soliton' corresponding to node-'Soliton'
parameterStruct.Soliton = [];

% target child node tag names in 'Soliton'
TARGET_CHILD = {'Parameter'};

% nodes with tag name as 'Soliton'
for i = 1:length(TARGET_INDEX)
    % i-th Soliton node's Attributes-(Start, End, lcenter, repeller)
    tempAttributes = xmlChildStruct(TARGET_INDEX(i)).Attributes;
    % create field-'Configuration' in the struct to store the Attributes of 'Soliton' node
    for m = 1:length(tempAttributes)
        parameterStruct.Soliton(i).Configuration.(tempAttributes(m).Name) = str2double(tempAttributes(m).Value);
    end
    
    % i-th Soliton's child nodes
    tempChild = xmlChildStruct(TARGET_INDEX(i)).Children;
    % child nodes' tag names
    tempName = {tempChild.Name};
    
    % nodes with tag name as 'Parameter'
    % nodes' index in Soliton
    tempIndex = find(strcmp(tempName, TARGET_CHILD{1}));
    % check the existence of 'Parameter' node
    if isempty(tempIndex)
        fprintf('ERROR: No element with tag name as ''%s'' in ''%s''!\n', TARGET_CHILD{1}, TARGET_TAG);
        return;
    end
    % read 'Parameter' nodes
    for j = 1:length(tempIndex)
        % j-th 'Parameter' node
        tempElement = tempChild(tempIndex(j));
        
        % 'Parameter' node's Attributes-(name)
        if strcmp(tempElement.Attributes.Name, 'name')
            % get the soliton varibale's name from value
            tempField = tempElement.Attributes.Value;
            % create corresponding field in the struct
            parameterStruct.Soliton(i).Parameter.(tempField) = [];

            % child nodes of 'Parameter' node to descript the soliton variable's value and its changes
            % TagName->Start : variable's start value and reverse value(???)
            % TagName->Linear : variable's value changes from (start, startv) to (end, endv) linearly
            % TagName->Exponential : variable's value changes from (start, startv) to (end, endv) exponentially
            tempCounter = 0; % counter of Changes
            for k = 1:length(tempElement.Children)
                % k-th child node of 'Parameter' node
                tempEleChild = tempElement.Children(k);
                % child node's tag name
                tempEleName = tempEleChild.Name;
                
                switch tempEleName
                    case 'Start' % Attributes-(value, rvalue)
                        switch length(tempEleChild.Attributes)
                            case 1
                                parameterStruct.Soliton(i).Parameter.(tempField).Start = str2double(tempEleChild.Attributes.Value);
                            otherwise
                                % attributes with name-'value'
                                parameterStruct.Soliton(i).Parameter.(tempField).Start(1,1) = str2double(tempEleChild.Attributes(strcmp({tempEleChild.Attributes.Name}, 'value')).Value);
                                % attributes with name-'rvalue'
                                parameterStruct.Soliton(i).Parameter.(tempField).Start(1,2) = str2double(tempEleChild.Attributes(strcmp({tempEleChild.Attributes.Name}, 'rvalue')).Value);
                        end % END SWITCH
                    case {'Linear', 'Exponential'} % Attributes-(start, startv, end, endv)
                        % create field-'Changes' if tempCounter == 0
                        if tempCounter == 0 
                            parameterStruct.Soliton(i).Parameter.(tempField).Changes = [];
                        end
                        % increase tempCounter by 1
                        tempCounter = tempCounter + 1;
                        % Type of Changes: 'Linear' or 'Exponential'
                        parameterStruct.Soliton(i).Parameter.(tempField).Changes(tempCounter).Type = tempEleName;
                        % Value matrix of Changes to store the start point and end point
                        % -[ start startv ]
                        % -[ end   endv   ]
                        parameterStruct.Soliton(i).Parameter.(tempField).Changes(tempCounter).Value = nan(2,2);                       
                        for m = 1:length(tempEleChild.Attributes)
                            switch tempEleChild.Attributes(m).Name
                                case 'start' 
                                    tempRC = [1 1];
                                case 'startv'
                                    tempRC = [1 2];
                                case 'end'
                                    tempRC = [2 1];
                                case 'endv'
                                    tempRC = [2 2];
                                otherwise
                                    tempRC = [];
                            end % END SWITCH
                            parameterStruct.Soliton(i).Parameter.(tempField).Changes(tempCounter).Value(tempRC(1),tempRC(2)) = str2double(tempEleChild.Attributes(m).Value);
                        end % END FOR-m
                end % END SWITCH
            end % END FOR-k
        end % END IF
    end % END FOR-j
        
end % END FOR-i




end

