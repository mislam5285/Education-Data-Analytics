%% load the data
load main_sara_data.mat store student;

%%
% filter students who are 

index = student.max_DurationAtUni ~= student.mean_DurationAtUni;
student.isFullTime = ~index;

sum(student.isFullTime) / numel(student.isFullTime)

%% filter the table with only full time students;

student_ = student(student.isFullTime,1:5);

%% Filter the acadmic result table, retaining only full time students
[academic,ia,ib] = outerjoin(student_,store,'Type','right', 'keys', 'StudentIDCode');
academic.StudentIDCode_store=[];
academic.Properties.VariableNames{'StudentIDCode_student_'} = 'StudentIDCode';

%%
clear store student student_

%%
index = isundefined( academic.StudentIDCode );
academic(index,:) =[];

%%
tmp=char(academic.StudentIDCode);
studentID = cell(size(tmp,1),1);
for i=1:size(tmp,1),
  studentID{i} = tmp(i,:);
end;
academic.StudentIDCode = studentID;
%% Find the modules
moduleList = unique(academic.ModuleCode);
studentList= unique(academic.StudentIDCode);

mapObj = containers.Map(moduleList,1:numel(moduleList));
idObj = containers.Map(studentList,1:numel(studentList));

%%
%http://uk.mathworks.com/help/matlab/ref/containers.map-class.html
%http://uk.mathworks.com/help/matlab/ref/sparse.html#bul62_1

%% create the sparse matrix

%%
row=cell2mat(values(idObj, academic.StudentIDCode));
col=cell2mat(values(mapObj, academic.ModuleCode));
%%
mat=sparse(row, col, academic.Mark, numel(keys(idObj)), numel(keys(mapObj)));
%%
mat_ = full(mat);

%% clustering to find program pathways

idx = kmeans(mat_>0,20);
hist(idx,1:20)
%%
for i=1:20;
  index=idx==i;
  subplot(4,5,i);
  imagesc(mat_(index(1:100),:)>0);
end;
%%
Modules_ = sum(mat_> 0,2);

%%
imagesc(mat); colorbar
%%

%%
hist(academic.Mark,100)
%%
mat(:)