%% Cont. Prepare the data
    % This Script is to create a table about students with student IDs as a key
    % and generate extra inormation about their achived levels
    
load main_sara.mat store;

%%
student = grpstats(store, {'StudentIDCode'}, {'max','mean'} ,'DataVars',{'Mark', 'DurationAtUni'});

%% process the level
    % NQF level by number 1= level 4 , 2 = level 5, 3= level 6, 4= Placement
    % NOTE: Placement year is usually optional.
    
[g_, id_] = findgroups(store.NQFName);
store.Level = g_;
metadata.Level = id_;

clear g_ id_;

%%
level_=grpstats(store, {'StudentIDCode'}, {'max'} ,'DataVars',{'Level'});
student.max_Level=level_.max_Level;

%%
% tabulate(student.max_Level)

%% count of levels
%
store.StudentIDCode=cellstr(store.StudentIDCode);
store.StudentIDCode=categorical(store.StudentIDCode);
%
s_=grpstats(store, {'StudentIDCode','NQFName'}, {'mean'} ,'DataVars',{'Mark'});
studentslevelcount=tabulate(s_.StudentIDCode);
studentslevelcount(:,3)=[];
studentslevelcount=cell2table(studentslevelcount, 'VariableNames',{'StudentIDCode', 'LevelCount'});
student.LevelCount=studentslevelcount.LevelCount;

clear s_;

%%
save main_sara.mat store student;
