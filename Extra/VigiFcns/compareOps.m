fns=fieldnames(ops1);
for i=1:length(fns)
    if ~isequal(ops1.(fns{i}),ops.(fns{i}))
        disp(fns{i})
        disp(ops1.(fns{i}))
    end
end