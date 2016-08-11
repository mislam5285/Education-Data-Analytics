function p = ModulesStudentCount(pathcode,academic)

temp_ = academic(academic.PathCode==pathcode,{'Level','ModuleCode'});
temp_ = tabulate(temp_.ModuleCode);
p = cell2table(temp_);

p(p{:,2}==0,:)=[];

p(:,3)=[];

p.Properties.VariableNames{1}='ModuleCode';
p.Properties.VariableNames{2}='StudentNumbers';
end