function bString = bool2string(bValue)
%% Summary of BOOL2STRING 
% Description : convert bool value(true or false) to string('true' or 'false')
% Author : J.Dai
% Created Date : 2015.02.05

%%
bValue = logical(bValue);

BoolString = {'true', 'false'};

bString = BoolString{(bValue == true) + 2*(bValue == false)}; 

end

