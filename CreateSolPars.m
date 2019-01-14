function SolPars = CreateSolPars(XMLPath)
%% CreateSolPars
% Function Description:
% Author: J.Dai
% Created Date: 2015.12.03
% Last Modified Date: 2015.12.03
% Call function: ReadParameters();

%%
% read XML file
XML = ReadParameters(XMLPath);

% SolPars for {c, m, b, d, e, q}_i
SolPars = struct('c',[],'m',[],'b',[],'d',[],'e',[],'q',[]);

% get parameters for each C-alpha
TempSolitons = XML.Soliton;
for iS = 1:numel(TempSolitons)
    for i = TempSolitons(iS).Configuration.Start:TempSolitons(iS).Configuration.End
        if i <= TempSolitons(iS).Configuration.lcenter
            SolPars(i).c = TempSolitons(iS).Parameter.c.Start;
            SolPars(i).m = TempSolitons(iS).Parameter.m.Start;
        else
            SolPars(i).c = TempSolitons(iS).Parameter.c2.Start;
            SolPars(i).m = TempSolitons(iS).Parameter.m2.Start;
        end        
        SolPars(i).b = TempSolitons(iS).Parameter.b.Start;
        SolPars(i).d = TempSolitons(iS).Parameter.d.Start;
        SolPars(i).e = TempSolitons(iS).Parameter.e.Start;
        SolPars(i).q = TempSolitons(iS).Parameter.q.Start;
    end
end


end

