%%
load main_sara.mat academic 

%% Find the academic pathway based on the L5 common modules
L5academic = academic(academic.Level == 2,:);

%%
tmp_ = char(L5academic.StudentIDCode);
studentID = cell(size(tmp_,1),1);
for i = 1:size(tmp_,1),
  studentID{i} = tmp_(i,:);
end;
L5academic.StudentIDCode = studentID;
clear i tmp_ studentID;

%%
tmp_ = char(L5academic.ModuleCode);
Module = cell(size(tmp_,1),1);
for i=1:size(tmp_,1),
  Module{i} = tmp_(i,:);
end;
L5academic.ModuleCode = Module;
clear i tmp_ Module;

%% V1: Logical Matrix ( simple  ) 

id = L5academic.StudentIDCode;
m = L5academic.ModuleCode;

[idu,~,idc] = unique(id);
[mu,~,mc] = unique(m);

logMat3 = false(numel(idu),numel(mu));
logMat3(sub2ind(size(logMat3),idc,mc)) = true;


%% instead of having the decimal equivalent : get the index to the unique rows of LogMat 

[C3, ia3, l5pathindex_] = unique(logMat3,'rows');

%
PathwayL5 = table(idu,l5pathindex_,'VariableNames',{'StudentIDCode','L5PathCode'});
PathwayL5.L5PathCode = num2str(PathwayL5.L5PathCode,'%04d');

%% convert the logical matrix to table to explore the data  
% add the student id as row names and modules code as Varible names (header)  
mu=strcat('m',mu); % Variable names must start with a letter 
logMat3=array2table(logMat3,'RowNames',idu,'VariableNames',mu);

%%
clear id idu idc m mu mc;

%% 
PathwayL5.StudentIDCode = categorical(PathwayL5.StudentIDCode);
PathwayL5.L5PathCode = cellstr(PathwayL5.L5PathCode);
PathwayL5.L5PathCode = categorical(PathwayL5.L5PathCode);

%% Explore the pathways
sortedL5Path=sortrows(tabulate(PathwayL5.L5PathCode),-2);
length(unique(PathwayL5.L5PathCode));

%% Add PathCode to academic
[academic] = outerjoin(academic,PathwayL5,'Type','right','keys','StudentIDCode');
academic.StudentIDCode_PathwayL5=[];
academic.Properties.VariableNames{'StudentIDCode_academic'} = 'StudentIDCode';

%%
% save main_sara.mat pathway academic 