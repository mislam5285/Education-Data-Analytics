
function R= processPathRecords(pathRecords)

%
tmp_ = char(pathRecords.StudentIDCode);
s_ = cell(size(tmp_,1),1);
for i = 1:size(tmp_,1),
  s_{i} = tmp_(i,:);
end;
pathRecords.StudentIDCode = s_;
clear i tmp_ s_;

%
tmp_ = char(pathRecords.ModuleCode);
m_ = cell(size(tmp_,1),1);
for i=1:size(tmp_,1),
  m_{i} = tmp_(i,:);
end;
pathRecords.ModuleCode = m_;
clear i tmp_ m_;

%
modules_ = unique(pathRecords.ModuleCode);
studentList_ = unique(pathRecords.StudentIDCode);

%
mapObj = containers.Map(modules_,1:numel(modules_));
idObj = containers.Map(studentList_,1:numel(studentList_));

%
row = cell2mat(values(idObj, pathRecords.StudentIDCode));
col = cell2mat(values(mapObj, pathRecords.ModuleCode));

% the sparse function will create a zero value if the student doesn't have a registered
% value for any module .. so to distinguish between the acual zero mark and 
% not availble mark, I have replace each real zero mark with a number out of the
% mark range(0-100) => -1

%pathRecords.Mark(pathRecords.Mark==0)=-1;

% create a table where each module is represented as avariable (column) 
% Using  MARKs as values for modules columns
mat_ = sparse(row, col, pathRecords.MarkClass, numel(keys(idObj)), numel(keys(mapObj)));
mat = full(mat_);

% replce any zero value NaN => indicate that the student has not taken that module
mat( mat==0 )= NaN;

% bring back the real zero value marks =>  indicate that the student has taken 0 in that module
mat( mat== -1 )= 0;

% Variable names must start with a letter 
modules_ = strcat('m',modules_);  

% each student is represented by one row 
mat = array2table(mat,'RowNames',studentList_,'VariableNames',modules_);
mat.StudentIDCode=studentList_;

% join the modules record table with the acadmic table
vars={ 'StudentIDCode','GenderCode','NationalityCode','StartYear','EndYear',...
    'PathCode','L4PathCode','L5PathCode','L6PathCode','LevelCount',...
    'ModulesCount','max_Mark','mean_Mark'};

R_ = pathRecords(:,vars);
R_=unique(R_,'rows');

[R] = outerjoin(R_,mat,'Type','right','keys','StudentIDCode');

R.StudentIDCode_mat = [];
R.Properties.VariableNames{1} = 'StudentIDCode';


end