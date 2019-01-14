function diginto(thestruct, level)
% Display Tree of a struct variable. Call it directly, diginto(struct);
% From: http://code.activestate.com/recipes/576489-matlab-code-for-displaying-struct-details/
% Modified my http://blog.macro2.org

if nargin < 2
    level = 0;
end

fn = fieldnames(thestruct);

for n = 1:length(fn)
    fprintf('%s%s\n',repmat('   ',1,level),fn{n}); %Modified: for better performance
 
    fn2 = getfield(thestruct,fn{n});
    
    if isstruct(fn2)
        diginto(fn2, level+1);
    elseif iscell(fn2)&&isstruct(fn2{1}) %Modified: In case of a struct array.
        for h=1:length(fn2)
            diginto(fn2{h},level+1);
        end
    end
end

end