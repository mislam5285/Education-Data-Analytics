%%
load main_sara.mat academic 

%% Find the academic pathway based on the L4 and L5 common modules
L4L5academic = academic(academic.Level == 1 | academic.Level == 2,:);

%%
tmp_ = char(L4L5academic.StudentIDCode);
studentID = cell(size(tmp_,1),1);
for i = 1:size(tmp_,1),
  studentID{i} = tmp_(i,:);
end;
L4L5academic.StudentIDCode = studentID;
clear i tmp_ studentID;

%%
tmp_ = char(L4L5academic.ModuleCode);
Module = cell(size(tmp_,1),1);
for i=1:size(tmp_,1),
  Module{i} = tmp_(i,:);
end;
L4L5academic.ModuleCode = Module;
clear i tmp_ Module;

%% V1: Logical Matrix ( simple  ) 

id = L4L5academic.StudentIDCode;
m = L4L5academic.ModuleCode;

[idu,~,idc] = unique(id);
[mu,~,mc] = unique(m);

logMat = false(numel(idu),numel(mu));
logMat(sub2ind(size(logMat),idc,mc)) = true;

%% V2: Logical matrix ( using containers.Map + sparse)
%{
L4L5ModuleList = unique(L4L5academic.ModuleCode);
StudentList = unique(L4L5academic.StudentIDCode);
L4L5academic.RegisteredModule = ones(height(L4L5academic),1);

% test: map the value of the registered module variable 
% the results are the same with or without the maping 
%{
tmp_ = char(L4L5academic.RegisteredModule);
rm_ = cell(size(tmp_,1),1);
for i=1:size(tmp_,1),
  rm_{i} = tmp_(i,:);
end;
L4L5academic.RegisteredModule = rm_;
clear i tmp_ rm_;
%}
%

mapObj = containers.Map(L4L5ModuleList,1:numel(L4L5ModuleList));
idObj = containers.Map(StudentList,1:numel(StudentList));
% rObj = containers.Map(L4L5academic.RegisteredModule,1:numel(L4L5academic.RegisteredModule));

%
row = cell2mat(values(idObj, L4L5academic.StudentIDCode));
col = cell2mat(values(mapObj, L4L5academic.ModuleCode));
% rm = cell2mat(values(rObj, L4L5academic.RegisteredModule));

% create a binary vectore for each student based on L4 and L5 registered modules
mat = sparse(row, col, L4L5academic.RegisteredModule, numel(keys(idObj)), numel(keys(mapObj)));
logMat2 = full(mat);

%mat2 = sparse(row, col, rm, numel(keys(idObj)), numel(keys(mapObj)));
%mat2_ = full(mat);

%
clear row col idObj mapObj mat;
%clear rObj rm;
%}
%% convert the binery hashes to decimal numbers 
% something wrong : there are students with different modules group have the same decimal hash
% Reason : the bi2de dosenot convert a binary number larger than 52 bit..
%{ 
PathHash = cell(size(logMat,1),1);

for  i = 1:size(logMat,1),
    PathHash{i} = bi2de(logMat(i,:));
end;
clear i;

%V1
Pathway = table(idu,PathHash,'VariableNames',{'StudentIDCode','PathHash'});
%V2:
%Pathway = table(StudentList,PathHash,'VariableNames',{'StudentIDCode','PathHash'});
%}
%% Create simpler code (increamental starts from 1 )
% no more is needed 
%{
Pathway.PathHash =cell2mat(Pathway.PathHash);
Pathway = sortrows(Pathway,'PathHash','ascend'); % sort the paths
PathCode = zeros(size(Pathway,1),1);
c_ = 1;
p_ = Pathway.PathHash(1);
for i = 1:size(Pathway,1)
    if Pathway.PathHash(i) == p_
        PathCode(i) = c_;
    elseif Pathway.PathHash(i) ~= p_
        c_ = c_ + 1;
        p_ = Pathway.PathHash(i);
        PathCode(i) = c_;
    end;
end;
clear i c_ p_;

Pathway.PathCode = num2str(PathCode,'%04d');
%}
%% instead of having the decimal equivalent : get the index to the unique rows of LogMat 

[C, ia, pathindex_] = unique(logMat,'rows');

%
Pathway = table(idu,pathindex_,'VariableNames',{'StudentIDCode','PathCode'});
Pathway.PathCode = num2str(Pathway.PathCode,'%04d');

%% convert the logical matrix to table to explore the data  
% add the student id as row names and modules code as Varible names (header)  
mu=strcat('m',mu); % Variable names must start with a letter 
logMat=array2table(logMat,'RowNames',idu,'VariableNames',mu);

%%
clear id idu idc m mu mc;

%% 
%Pathway.PathHash = num2str(Pathway.PathHash);
%Pathway.PathHash = cellstr(Pathway.PathHash);
Pathway.PathCode = cellstr(Pathway.PathCode);
Pathway.StudentIDCode = categorical(Pathway.StudentIDCode);
%Pathway.PathHash = categorical(Pathway.PathHash);
Pathway.PathCode = categorical(Pathway.PathCode);

%% Explore the pathways
sortedPath=sortrows(tabulate(Pathway.PathCode),-2);
length(unique(Pathway.PathCode));

%% Add PathCode to academic
[academic] = outerjoin(academic,Pathway,'Type','right','keys','StudentIDCode');
academic.StudentIDCode_Pathway=[];
academic.Properties.VariableNames{'StudentIDCode_academic'} = 'StudentIDCode';


%%
% save main_sara.mat pathway academic 