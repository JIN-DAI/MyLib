function EmptyTerminal = CreateEmptyTerminal()
%% CREATEEMPTYTERMINALSECTION TITLE
% Description: create a struct for empty terminal of one model which are related to pdbread/pdbwrite functions.
% Author: J.Dai
% Latest Modified Date: 2015.01.19


%% empty terminal
EmptyTerminal.SerialNo = NaN;
EmptyTerminal.resName = '';
EmptyTerminal.chainID = '';
EmptyTerminal.resSeq = NaN;
EmptyTerminal.iCode = '';


end

