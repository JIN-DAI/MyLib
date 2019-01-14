function struct1 = catStruct(struct1, struct2)
%% CATSTRUCT
% concatenate all fields in struct2 into struct1

%%
fn = fieldnames(struct2);
for i = 1:length(fn)
    struct1.(fn{i}) = struct2.(fn{i});
end


end

