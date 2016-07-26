%% Explore the data 
    % This script is to explore the data, pick random samples, find outliers and filter out incomplete and incompatible records 

load main_sara.mat store student;

%%
% The store table's columns names
store.Properties.VariableNames

%% Counts 
% original students count = 6652
studentsCount=length(unique(store.StudentIDCode));

%%
% number of students' nationalties = 123
length(unique(store.NationalityCode));
%%
% number of modules = 420
length(unique(store.ModuleCode));

%% Frequency Exploration
% Gender
tabulate(store.GenderCode)
%%
% Classification
sortrows(tabulate(store.ClassificationName),-2)

%%
% Module
sortrows(tabulate(store.ModuleCode),2)

%% Check for strange data points
% grpstats(store, {'NationalityCode','GenderCode'}, {'mean'} ,'DataVars',{'Mark'})
% select mean(Mark) from STORE GROUP BY NationalityCode and GenderCode

%%
tabulate(student.max_DurationAtUni)

%%
plot(student.GroupCount,student.max_DurationAtUni,'.')
xlabel('Number of modules taken');
ylabel('Duration at Uni');

%% check random records
% store(store.StudentIDCode=='391712945',:) %end date is before the the start date if the format is mm/dd/yyyy

%% Exploring and Filtering out incomplete students records 

% Explore and find incomplete students records that should be removed (by levels)
tabulate(student.LevelCount)
histogram(categorical(student.LevelCount))

%  
% student(student.LevelCount==1,:); % students who have only one level in their records
% student(student.max_Level==1 & student.LevelCount==1,:); % students who have only L4 in their records 
% student(student.max_Level==2 & student.LevelCount==1,:); % students who have only L5 in their records
% student(student.max_Level==3 & student.LevelCount==1,:); % students who have only L6 in their records
% student(student.max_Level==4 & student.LevelCount==1,:); % students who have only P in their records

% student(student.max_Level==3 & student.LevelCount==2,:); % students who are up to l6 but missing either L4 or L5 records
% student(student.max_Level==4 & student.LevelCount==2,:); % students who have taken placement year but have incomplete level records


%% Filter out students with only one level records = 594 students
onlyOneLevel_=student(student.LevelCount==1,{'StudentIDCode'});
clear index_;
index_=~ismember(store.StudentIDCode,onlyOneLevel_.StudentIDCode);
store=store(index_,:);
clear index_;
index_=~ismember(student.StudentIDCode,onlyOneLevel_.StudentIDCode);
student=student(index_,:);
clear onlyOneLevel_ index_;

%% Filter out students who has the max level = 3 & level count = 2 <<incomplete records
max3count2Level_=student(student.max_Level==3 & student.LevelCount==2,{'StudentIDCode'});
clear index_;
index_=~ismember(store.StudentIDCode,max3count2Level_.StudentIDCode);
store=store(index_,:);
clear index_;
index_=~ismember(student.StudentIDCode,max3count2Level_.StudentIDCode);
student=student(index_,:);
clear max3count2Level_ index_;

%% Filter out students who has the max level = 4 & level count = 2 <<incomplete records
max4count2Level_=student(student.max_Level==4 & student.LevelCount==2,{'StudentIDCode'});
clear index_;
index_=~ismember(store.StudentIDCode,max4count2Level_.StudentIDCode);
store=store(index_,:);
clear index_;
index_=~ismember(student.StudentIDCode,max4count2Level_.StudentIDCode);
student=student(index_,:);
clear max4count2Level_ index_;

%% Filter out students who have incomplete records ..
    % Any student who has max level=4, levels count=3, and has l6 in his/her
    % records =>is missing either l4 or l5 <<thus they should be removed for
    % incompletness
m4c3_=student(student.max_Level==4 & student.LevelCount==3,{'StudentIDCode'});
clear index_;
index_=ismember(store.StudentIDCode,m4c3_.StudentIDCode);
max4count3Level=store(index_,:);

t_=max4count3Level(max4count3Level.Level==3,{'StudentIDCode'});
t_=unique(t_);
%l6_=store(ismember(store.StudentIDCode,t.StudentIDCode),:);
%grpstats(l6, {'StudentIDCode','NQFName'}, {'mean'} ,'DataVars',{'Mark'})

store=store(~ismember(store.StudentIDCode,t_.StudentIDCode),:);

clear t_ index_ m4c3_ max4count3Level;


%% Explore students who have only L4 L5 and L6 records 
max3count3Level_=student(student.max_Level==3 & student.LevelCount==3,{'StudentIDCode'});
clear index_;
index_=ismember(store.StudentIDCode,max3count3Level_.StudentIDCode);
tempstore=store(index_,:);
clear index_;
index_=ismember(student.StudentIDCode,max3count3Level_.StudentIDCode);
tempstudent=student(index_,:);
clear max3count3Level_ index_;

% find the students who have invalid records in this set 
M3C3invalidst_=tempstore(tempstore.ClassificationName=='INVALID',:);
M3C3invalidStudentList_=unique(invalidst_.StudentIDCode);

index_=ismember(store.StudentIDCode,invalidStudentList);
vars={ 'StudentIDCode','ClassificationName','NQFName','EndDate','ReasonForTransferName','ModuleCode','Mark','DurationAtUni'};
M3C3invalidmax3count3_=store(index_,vars);

%%
clear M3C3invalidst_ M3C3invalidStudentList_ M3C3invalidmax3count3_

%% Explore Invalid students
invalidst_=store(store.ClassificationName=='INVALID',:);
invalidStudentList=unique(invalidst_.StudentIDCode);

%% generate 2 lists : students how have some invalid  and students who has all invalid records.
clear index_ is_ t_ ;

index_=ismember(store.StudentIDCode,invalidStudentList);
invalidstore_=store(index_,vars);
is_=grpstats(invalidstore_, {'StudentIDCode','ClassificationName'}, {'mean'} ,'DataVars',{'Mark'});
t_=sortrows(tabulate(is_.StudentIDCode),-2);
t_(:,3)=[];
t_=cell2table(t_);
todelete_=t_.t_2==0;
t_(todelete_,:)=[];
tabulate(t_.t_2)

someInvalidSTlist_=t_(t_.t_2==2,{'t_1'}); %32
allInvalidSTlist_=t_(t_.t_2==1,{'t_1'}); %222

clear index_ is_ t_ ;

%% remove students with some invalid records
    % someInvalidIndex_ : students who has both invalid and valid records
    
someInvalidIndex_=ismember(store.StudentIDCode,someInvalidSTlist_.t_1);
vars={ 'StudentIDCode','ClassificationName','NQFName','EndDate',
    'ReasonForTransferName','ModuleCode','Mark','DurationAtUni'};
someInvalidStore_=store(someInvalidIndex_,vars); % Explore the data

% remove the invalid records ..
invalidIndex_=store.ClassificationName=='INVALID'; %invalidindex_ : all the invalid
store(someInvalidIndex_ & invalidIndex_,:)=[];

% store = store(~(someInvalidIndex_ & invalidIndex_),:);

clear someInvalidIndex_ invalidIndex_ some someInvalidSTlist_ someInvalidStore_;

%% Student with all invalid records
allInvalidIndex_=ismember(store.StudentIDCode,allInvalidSTlist_.t_1);
vars={ 'StudentIDCode','ClassificationName','NQFName','EndDate','ReasonForTransferName','ModuleCode','Mark','DurationAtUni'};
allInvalidStore_=store(allInvalidIndex_,vars); % Explore the data

%% Filter out all inavlid records 
%{ 
invalidIndex_=store.ClassificationName=='INVALID';
store(invalidIndex_,:)=[];
%}

%% Filter out students with only 2 levels
%{
max2count2Level_=student(student.max_Level==2 & student.LevelCount==2,{'StudentIDCode'});
clear index_;
index_=~ismember(store.StudentIDCode,max2count2Level_.StudentIDCode);
store=store(index_,:);
clear index_;
index_=~ismember(student.StudentIDCode,max2count2Level_.StudentIDCode);
student=student(index_,:);
clear max2count2Level_ index_;
%}

%% Deal with repeatitive modules (choose the max mark)
%{
temp_=grpstats(store, {'StudentIDCode', 'ModuleCode'}, {'max'} ,'DataVars',{'Mark'});
temp_(temp_.GroupCount==1,:)=[];
repeatitives=sortrows(tabulate(temp_.GroupCount));
for i=0:size(temp_,1)
    store(store.StudentIDCode==temp_.StudentIDCode(i) & store.ModuleCode~=temp_.max_Mark,:)=[];
end;
%}

%% update the invalid students list (now contains students with only all invalid records)
    % RUN: DP_03_students_and_levels.m
    
%% level 4 statistics
%temp_= ismember(store.StudentIDCode,twoOrMorelevelStudent.StudentIDCode);
%temp2_= store(temp_ & store.Level==1,:);
level4_= store(store.Level==1,:);
level4st_=grpstats(level4_, {'StudentIDCode'}, {'max'} ,'DataVars',{'Level'});
histogram(level4st_.GroupCount)

%% Join all data in one table
[academic,ia,ib] = outerjoin(student,store,'Type','right', 'keys', 'StudentIDCode');
academic.StudentIDCode_store=[];
academic.Properties.VariableNames{'StudentIDCode_student'} = 'StudentIDCode';

%%
save main_sara.mat store student academic;
