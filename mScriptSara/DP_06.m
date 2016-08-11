%%
load main_sara.mat academic ;

%% filter the table with only full time students;

index = academic.max_DurationAtUni ~= academic.mean_DurationAtUni;
academic.isFullTime = ~index;

% sum(academic.isFullTime) / numel(academic.isFullTime)

% student_ = academic(academic.isFullTime,1:5);
%%
studentpathsnan=grpstats(academic, {'StudentIDCode','PathCode','L4PathCode','L5PathCode'}, {'max'} ,'DataVars',{'Mark'});
L4toL5nan=grpstats(studentpathsnan, {'L4PathCode','L5PathCode'}, {'max'} ,'DataVars',{'max_Mark'});
%% Deal with repeatitive modules records (to keep the max mark)

temp_=grpstats(academic, {'StudentIDCode', 'ModuleCode'}, {'max'} ,'DataVars',{'Mark'});
temp_(temp_.GroupCount==1,:)=[];
% repeatitives=sortrows(tabulate(temp_.GroupCount));
for i=1:size(temp_,1),
    academic(academic.StudentIDCode==temp_.StudentIDCode(i) & academic.ModuleCode==temp_.ModuleCode(i) & academic.Mark~=temp_.max_Mark(i),:)=[];
end;
clear i temp_;

%% update the student's statistic 
academic.max_Mark=[];
academic.mean_Mark=[];
academic.GroupCount=[];

g=grpstats(academic, {'StudentIDCode'}, {'max','mean'} ,'DataVars',{'Mark'});

[academic] = outerjoin(academic,g,'Type','right','keys','StudentIDCode');
academic.StudentIDCode_g=[];
academic.Properties.VariableNames{'StudentIDCode_academic'} = 'StudentIDCode';
academic.Properties.VariableNames{'GroupCount'} = 'ModulesCount';

clear g;
%% create Marks classes

MC_=cell(size(academic,1),1);
for i=1:size(MC_,1),
    if isnan(academic.Mark(i))
      MC_{i}='';
    elseif academic.Mark(i)<40
      MC_{i}='F';
    elseif academic.Mark(i)>=40 && academic.Mark(i)<60
     MC_{i}='P';
    elseif academic.Mark(i)>=60 && academic.Mark(i)<70
      MC_{i}='M';
    elseif academic.Mark(i)>=70 
      MC_{i}='D';
    end;
end;
academic.MarkClass=MC_;
academic.MarkClass=categorical(cellstr(academic.MarkClass));
% academic.MarkClass(isundefined(academic.MarkClass)) = 'NaN';
clear i MC_


%%
% nanStudents=academic(isnan(academic.Mark),{'StudentIDCode'});
nanStudents=unique(academic(isnan(academic.Mark),{'StudentIDCode'}));

PNaN_=unique(academic(academic.Level==4 & isnan(academic.Mark),{'StudentIDCode'}));
L4NaN_=unique(academic(academic.Level==1 & isnan(academic.Mark),{'StudentIDCode'}));
L5NaN_=unique(academic(academic.Level==2 & isnan(academic.Mark),{'StudentIDCode'}));
L6NaN_=unique(academic(academic.Level==3 & isnan(academic.Mark),{'StudentIDCode'}));

clear index_ 
index_=ismember(academic.StudentIDCode,nanStudents.StudentIDCode)
NaNacademic=academic(index_,:);
NaNacademic.isMissing=isnan(NaNacademic.Mark);
temp_=grpstats(NaNacademic,{'StudentIDCode','isMissing'},{'max'} ,'DataVars',{'Mark'});
temp2_= temp_(temp_.isMissing==true,:);


temp2_(temp2_.GroupCount==8,:)

l4NaNr=bringRecords(L4NaN_,academic);

%% remove any student with nan records 
%{
clear index_ 
L4L5NaN=unique(academic(academic.Level<=2 & isnan(academic.Mark),{'StudentIDCode'}));
index_=ismember(academic.StudentIDCode,L4L5NaN.StudentIDCode);
academic(index_,:)=[];
%}