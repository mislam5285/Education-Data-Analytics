%% Get and process the data
path1360 = academic(academic.PathCode=='1360',:);
path1360 = processPathRecords(path1360);
%%
path1360.Properties.VariableNames

%% Marks estimation 

%% 1 - P(L5|L4) Predicate student L5 performance based on L4 performance

% only academic performance
features = [14:17];

%target = 18;  %m2001
% target = 19;  %m2002
% target = 20;  %m2003
% target = 21;  %m2004
target = 22;  %m2005

%% 2 - P(L6|L4,L5) Predicate student L6 performance based on L4 & L5 performance

% only academic performance
features = [14:22];

 target = 23;  %m3001
% target = 24;  %m3002
% target = 25;  %m3003
% target = 26;  %m3004
% target = 27;  %m3005

%%
path1360(29,:)=[];

%%
rng('default');
[trainInd,~,testInd] = dividerand(size(ds,1),7,0,3);

training = ds(trainInd,:);
testing = ds(testInd,:);
%% Neural network fitting
target_ = table2array(path1360(:,target));
edges_ =  [0 40 60 70 100];
target_ = discretize(target_, edges_); %{'F','P','M', 'D'});

ds = path1360;
ds.MarkClass=target_; 

train_X_ = table2array(ds(trainInd,features));
train_Y_ = table2array(ds(trainInd,{'MarkClass'}));

test_X_ = table2array(ds(testInd,features));
test_Y_ = table2array(ds(testInd,{'MarkClass'}));