function factors = FactorsUpdate(factors, newfactors)

allfields = fieldnames(newfactors);
for i = 1:length(allfields)
    if isfield(factors, allfields{i})
        factors.(allfields{i}) = newfactors.(allfields{i});
    end
end



end