%%
load main_sara.mat academic 

%% Find the academic pathway based on the L6 common modules
L6academic = academic(academic.Level == 3,:);

%%
tmp_ = char(L6academic.StudentIDCode);
studentID = cell(size(tmp_,1),1);
for i = 1:size(tmp_,1),
  studentID{i} = tmp_(i,:);
end;
L6academic.StudentIDCode = studentID;
clear i tmp_ studentID;

%%
tmp_ = char(L6academic.ModuleCode);
Module = cell(size(tmp_,1),1);
for i=1:size(tmp_,1),
  Module{i} = tmp_(i,:);
end;
L6academic.ModuleCode = Module;
clear i tmp_ Module;

%% V1: Logical Matrix ( simple  ) 

id = L6academic.StudentIDCode;
m = L6academic.ModuleCode;

[idu,~,idc] = unique(id);
[mu,~,mc] = unique(m);

logMat4 = false(numel(idu),numel(mu));
logMat4(sub2ind(size(logMat4),idc,mc)) = true;


%% instead of having the decimal equivalent : get the index to the unique rows of LogMat 

[C3, ia3, l6pathindex_] = unique(logMat4,'rows');

%
PathwayL6 = table(idu,l6pathindex_,'VariableNames',{'StudentIDCode','L6PathCode'});
PathwayL6.L6PathCode = num2str(PathwayL6.L6PathCode,'%04d');

%% convert the logical matrix to table to explore the data  
% add the student id as row names and modules code as Varible names (header)  
mu=strcat('m',mu); % Variable names must start with a letter 
logMat4=array2table(logMat4,'RowNames',idu,'VariableNames',mu);

%%
clear id idu idc m mu mc;

%% 
PathwayL6.StudentIDCode = categorical(PathwayL6.StudentIDCode);
PathwayL6.L6PathCode = cellstr(PathwayL6.L6PathCode);
PathwayL6.L6PathCode = categorical(PathwayL6.L6PathCode);

%% Explore the pathways
sortedL6Path=sortrows(tabulate(PathwayL6.L6PathCode),-2);
length(unique(PathwayL6.L6PathCode));

%% Add PathCode to academic
[academic,d1,d2] = outerjoin(academic,PathwayL6,'keys','StudentIDCode');
academic.StudentIDCode_PathwayL6=[];
academic.Properties.VariableNames{'StudentIDCode_academic'} = 'StudentIDCode';
academic.L6PathCode(isundefined(academic.L6PathCode)) = 'NO-L6';
%%
% save main_sara.mat pathway academic 