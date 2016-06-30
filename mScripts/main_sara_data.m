%% load data
ds = datastore('../data/Computing Data Request 170316.csv');
ds.MissingValue = 0;% Strategy for missing value
%%
ds.TextscanFormats{10}='%q';
reset(ds);
ds.ReadSize = 141840;
store = read(ds);

%% define the data type
store.StudentIDCode = categorical(store.StudentIDCode);

%% Check the data



unique(store.NationalityCode)'
%%
store.Properties.VariableNames'

%% Check for strange data points
grpstats(store, {'NationalityCode','GenderCode'}, {'mean'} ,'DataVars',{'Mark'})
% select sum(Mark) from STORE GROUP BY NationalityCode

%%
store(store.NationalityCode==655,:)

%%
student = grpstats(store, {'StudentIDCode'}, {'mean','max'} ,'DataVars',{'Mark','DurationAtUni'});

%%
histogram(student.GroupCount)

%% convert the date string
[date_y date_m] = datevec(store.EndDate,'dd/mm/yyyy');

clear tmp_;
for i=1:numel(date_y),
  tmp_{i} = sprintf('%d/%02d',date_y(i), date_m(i));
end;

% process the date
store.EndDate = tmp_';
store.EndYear = date_y;
store.EndMonth = date_m;
%
store.StartYear = cellfun( @(x) x(5:8), store.HesaStart,'UniformOutput', false);
store.StartYear = str2double(store.StartYear);
%
store.DurationAtUni = store.EndYear - store.StartYear;
%%
student = grpstats(store, {'StudentIDCode'}, {'max','mean'} ,'DataVars',{'Mark', 'DurationAtUni'});

% for i=1:size(student, 1),
%   student.StudentIDCode{i}
% end;
%%
plot(student.GroupCount,student.max_DurationAtUni,'.')

%%
selected = find(student.max_DurationAtUni<0);
list = student.StudentIDCode(selected);
%%
store(store.StudentIDCode==list(1),:)
%%
for i=1:numel(list),
  selected_rows = store.StudentIDCode==list(i);
  date_ = store.EndDate(selected_rows);
  [date_y, date_m] = datevec(date_,'mm/yy');
  store.EndYear(selected_rows) = date_y;
  store.EndMonth(selected_rows) = date_m;
end;
%%
store.DurationAtUni = store.EndYear - store.StartYear;
student = grpstats(store, {'StudentIDCode'}, {'max','mean'} ,'DataVars',{'Mark', 'DurationAtUni'});
%%
plot(student.GroupCount,student.max_DurationAtUni,'.')
xlabel('Number of modules taken');
ylabel('Duration at Uni');

%%
store(store.StudentIDCode==student.StudentIDCode(1146),:)

%% process the level
[g_, id_] = findgroups( store.NQFName);
store.Level = g_;
metadata.Level = id_;

%% save 
save main_sara_data.mat store student;


