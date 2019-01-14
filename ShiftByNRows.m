function V = ShiftByNRows(V, N)
%% SHIFTBYNROWS
% shift vector V by N rows

%%
if N > 0
    V = [V(N+1:end,:); V(1:N,:)];
elseif N < 0
    V = [V((end+N+1):end,:); V(1:(end+N),:)];
elseif N == 0
    V = V;
end

