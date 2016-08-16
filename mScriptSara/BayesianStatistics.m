
load main_sara.mat academic;

%% INFO : 
    %%% Path # 1360
    %%% Students # 142
        %%% Start year :
        %%%   2009       64     45.07%
        %%%   2010       78     54.93%
        
    %%% L4 Modules number 4 : m1001 - m1002 - m1003 - m1004
    %%% L5 Modules number 5 : m2001 - m2002 - m2003 - m2004 - m2005
    
    %%% L6
        %%% Students numbers = 141
        %%% L6 paths varients number = 1 
        %%% L6 # 2605
            %%% Modules number 5: m3001 - m3002 - m3003 - m3004 - m3005
            
%% Get and process the data
path1360 = academic(academic.PathCode=='1360',:);
path1360 = processPathRecords(path1360);
%%
path1360.Properties.VariableNames
%%
path1360(29,:)=[];
%% Marks estimation 

%% 1 - P(L5|L4) Predicate student L5 performance based on L4 performance

% only academic performance
features = [14:17];

% target = 18;  %m2001
% target = 19;  %m2002
% target = 20;  %m2003
% target = 21;  %m2004
% target = 22;  %m2005

%% 2 - P(L6|L4,L5) Predicate student L6 performance based on L4 & L5 performance

% only academic performance
features = [14:22];

% target = 23;  %m3001
 target = 24;  %m3002
% target = 25;  %m3003
% target = 26;  %m3004
% target = 27;  %m3005

%% Generate training, validation and test sets

%% 1 - all years records
rng('default');
[trainInd,~,testInd] = dividerand(size(path1360,1),7,0,3);

training = path1360(trainInd,:);
testing = path1360(testInd,:);

%% 2 - train first year and test on the following year 
%{
training = path1360(path1360.StartYear=2009,:);
testing = path1360(path1360.StartYear=2009,:);
%}

%% Discretize the mark value for the classification 

target_ = table2array(path1360(trainInd,target));
edges_ =  [0 40 60 70 100];
Y_ = discretize(target_, edges_); %{'F','P','M', 'D'});

input_ = table2array(path1360(trainInd,features));

%%  Bayesian Statistics
status = {'F','P','M', 'D'};
mark_range = 0:100;
%for s_=1:4, 
s_=1;

figure(s_); clf; hold on;
for i=1:4,
  selected_row = Y_==i;
  [f_(i,:),x]=ksdensity(input_(selected_row,s_),mark_range);
  prior(i) = sum(selected_row)/numel(Y_);
  likelihood_prior(i,:)= f_(i,:);% * prior(i) ;
  plot(x,likelihood_prior(i,:));
  label_{i} = sprintf('%s (%d)', status{i}, sum(selected_row));
end;
legend(label_);

%% Posterior probability
posterior = likelihood_prior ./ repmat( sum(likelihood_prior), 4,1);

imagesc(posterior)

%%
X_ = table2array(path1360(trainInd,features));
Y_ = table2array(path1360(trainInd,target));
