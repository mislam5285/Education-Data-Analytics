%%
load main_sara.mat academic 

%% Find the academic pathway based on the L4 common modules
L4academic = academic(academic.Level == 1,:);

%%
tmp_ = char(L4academic.StudentIDCode);
studentID = cell(size(tmp_,1),1);
for i = 1:size(tmp_,1),
  studentID{i} = tmp_(i,:);
end;
L4academic.StudentIDCode = studentID;
clear i tmp_ studentID;

%%
tmp_ = char(L4academic.ModuleCode);
Module = cell(size(tmp_,1),1);
for i=1:size(tmp_,1),
  Module{i} = tmp_(i,:);
end;
L4academic.ModuleCode = Module;
clear i tmp_ Module;

%% V1: Logical Matrix ( simple  ) 

id = L4academic.StudentIDCode;
m = L4academic.ModuleCode;

[idu,~,idc] = unique(id);
[mu,~,mc] = unique(m);

logMat2 = false(numel(idu),numel(mu));
logMat2(sub2ind(size(logMat2),idc,mc)) = true;


%% instead of having the decimal equivalent : get the index to the unique rows of LogMat 

[C2, ia2, l4pathindex_] = unique(logMat2,'rows');

%
PathwayL4 = table(idu,l4pathindex_,'VariableNames',{'StudentIDCode','L4PathCode'});
PathwayL4.L4PathCode = num2str(PathwayL4.L4PathCode,'%04d');

%% convert the logical matrix to table to explore the data  
% add the student id as row names and modules code as Varible names (header)  
mu=strcat('m',mu); % Variable names must start with a letter 
logMat2=array2table(logMat2,'RowNames',idu,'VariableNames',mu);

%%
clear id idu idc m mu mc;

%% 
PathwayL4.StudentIDCode = categorical(PathwayL4.StudentIDCode);
PathwayL4.L4PathCode = cellstr(PathwayL4.L4PathCode);
PathwayL4.L4PathCode = categorical(PathwayL4.L4PathCode);

%% Explore the pathways
sortedL4Path=sortrows(tabulate(PathwayL4.L4PathCode),-2);
length(unique(PathwayL4.L4PathCode));

%% Add PathCode to academic
[academic] = outerjoin(academic,PathwayL4,'Type','right','keys','StudentIDCode');
academic.StudentIDCode_PathwayL4=[];
academic.Properties.VariableNames{'StudentIDCode_academic'} = 'StudentIDCode';

%%
% save main_sara.mat pathway academic 