%% Fix and prepare the data
    % This script is to fix date inconsistent format,
    % and calculate the duration that a student spends in Uni.

load main_sara.mat store;

%% Unify the inconsistent students' date of birth format ..to mm/dd/yyyy
% The date values in the original data set are inconsistent format .. 
    % some dates are in short mm/dd/yy format and some are in long mm/dd/yyyy format

for i=1:length(store.StudentDateOfBirth),
    
    if length(store.StudentDateOfBirth{i})==6 || length(store.StudentDateOfBirth{i})==7 ...
            || length(store.StudentDateOfBirth{i})==8
       
        d=datenum(store.StudentDateOfBirth{i},'mm/dd/yy');
        store.StudentDateOfBirth{i}=datestr(d,'mm/dd/yyyy');
    end;
    
end;
clear d i;

%% Get the start year from the start date (HesaStart)
store.StartYear = cellfun( @(x) x(5:8), store.HesaStart,'UniformOutput', false);
store.StartYear = str2double(store.StartYear);

%% Get the end  month and the end year from the end date 
    % and unify the End Date format to mm/dd/yyyy

% NOTE: 
    % For the 0/0/0 dates - I assign 0 value for the month the year  
    % this will give error and negative values when calculating the duration ..
    % I might consider the the levels count instead of the timely duration 


% V.1 : assuming all dates are in mm/dd/yyyy or mm/dd/yy

EndDate_y = cell(size(store,1),1);
EndDate_m = cell(size(store,1),1);

for i=1:length(store.EndDate),
    
    if length(store.EndDate{i})==5
        % should 0/0/0 be '' or NaN ?
        % or it should be given a value approximate value based on the student level .. or if the student has another end date ?
        EndDate_y(i,1)=0;
        EndDate_m(i,1)=0;
        
    elseif length(store.EndDate{i})==6 || length(store.EndDate{i})==7 || length(store.EndDate{i})==8
        d=datenum(store.EndDate{i},'mm/dd/yy');
        store.EndDate{i}=datestr(d,'mm/dd/yyyy');
        [EndDate_y(i,1), EndDate_m(i,1)] = datevec(store.EndDate{i},'mm/dd/yyyy');
        
    elseif length(store.EndDate{i})==9 || length(store.EndDate{i})==10
        [EndDate_y(i,1), EndDate_m(i,1)] = datevec(store.EndDate{i},'mm/dd/yyyy');
        
    end;
    
end;
clear d i;

%% 
% V.2 : assuming short date format is dd/mm/yy and long date format is mm/dd/yyyy
%{
clear i;
for i=1:length(store.EndDate),
    if length(store.EndDate{i})==5
        EndDate_y(i,1)=0;
        EndDate_m(i,1)=0;
    elseif length(store.EndDate{i})==6 || length(store.EndDate{i})==7 || length(store.EndDate{i})==8
        [EndDate_y(i,1), EndDate_m(i,1)] = datevec(store.EndDate{i},'dd/mm/yyyy');
    elseif length(store.EndDate{i})==9 || length(store.EndDate{i})==10
        [EndDate_y(i,1), EndDate_m(i,1)] = datevec(store.EndDate{i},'mm/dd/yyyy');
    end
end

% change yy to yyyy
clear i;

for i=1:numel(EndDate_y)
    if length(num2str(EndDate_y(i)))==2
      d=datenum(num2str(EndDate_y(i)),'yy');
      EndDate_y(i)=str2double(datestr(d,'yyyy'));
    end;
end;
%}
%% Calculate the duration

% Add EndDate_m, EndDate_y to store table
%{
clear tmp_;
for i=1:numel(EndDate_y),
  tmp_{i} = sprintf('%d/%02d', EndDate_m(i),EndDate_y(i));
end;
store.EndDate = tmp_';
%}
store.EndYear = EndDate_y;
store.EndMonth = EndDate_m;
%
store.DurationAtUni = store.EndYear - store.StartYear;

%%
unique(store.DurationAtUni); % gives negative values because of the zero values of 0/0/0

%%
save main_sara.mat store;


