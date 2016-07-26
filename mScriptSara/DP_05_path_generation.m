%%
% load main_sara.mat academic 
%% Find the academic pathway based on the L4 and L5 common modules
L4L5academic=academic(academic.Level==1 | academic.Level==2,{'StudentIDCode','ModuleCode','Mark','StartYear','Level','RegisteredModule'});

%%
tmp_=char(L4L5academic.StudentIDCode);
studentID = cell(size(tmp_,1),1);
for i=1:size(tmp_,1),
  studentID{i} = tmp_(i,:);
end;
L4L5academic.StudentIDCode = studentID;
clear i tmp_ 

%%
tmp_=char(L4L5academic.ModuleCode);
Module = cell(size(tmp_,1),1);
for i=1:size(tmp_,1),
  Module{i} = tmp_(i,:);
end;
L4L5academic.ModuleCode = Module;
clear i tmp_ 

%%
L4L5ModuleList = unique(L4L5academic.ModuleCode);
StudentList= unique(L4L5academic.StudentIDCode);
L4L5academic.RegisteredModule=ones(height(L4L5academic),1);

%%
mapObj = containers.Map(L4L5ModuleList,1:numel(L4L5ModuleList));
idObj = containers.Map(StudentList,1:numel(StudentList));

%%
row=cell2mat(values(idObj, L4L5academic.StudentIDCode));
col=cell2mat(values(mapObj, L4L5academic.ModuleCode));

%% create a binary vectore for each student based on L4 and L5 registered modules
mat=sparse(row, col, L4L5academic.RegisteredModule, numel(keys(idObj)), numel(keys(mapObj)));
mat_ = full(mat);
mat_(mat_>1)=1; % to deal with the repeatitive module for the same student . 

%% convert the binery hashes to decimal numbers 
PathHash=cell(size(mat_,1),1);
for  i=1:size(mat_,1),
    PathHash{i}= bi2de(mat_(i,:));
end;

Pathway=table(StudentList,PathHash);
% academic.PathHash=PathHash;
clear i

%% Explore the pathways
Pathway.PathHash=cell2mat(Pathway.PathHash);
Pathway.PathHash=num2str(Pathway.PathHash);
Pathway.PathHash=cellstr(Pathway.PathHash);
length(unique(Pathway.PathHash));
L4L5ModulesPathes=sortrows(tabulate(Pathway.PathHash),-2);

%% 
% save main_sara.mat pathway academic 