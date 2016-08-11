
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

%% Marks estimation 

%% 1 - P(L5|L4) Predicate student L5 performance based on L4 performance

% only academic performance
features = [14:17];

% including gender, nationality, start year
%features = [2:4 14:17];

% target = 18;  %m2001
% target = 19;  %m2002
% target = 20;  %m2003
 target = 21;  %m2004
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


%%
rng('default');
indices = crossvalind('Kfold', size(training, 1), 3); % cross validation on training or all  data set ?

%% ??? 

%plot(training{:,features},training{:,target},'x')
%xlabel('L4');
%ylabel('Mark');

% print(sprintf('figures/path1360_l4_vs_%s',training.Properties.VariableNames{target}),'-dpng');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1# LINEAR model: Create a fitted model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
clear Lmdl;
Lmdl = fitlm(training(:, [features, target]))

%% view the coefficients values , the model formula
Lmdl.CoefficientNames;
coefvals = Lmdl.Coefficients(:,1);
coefvals = table2array(coefvals);
Lmdl.Formula

%% Locate and remove outliers.
plotResiduals(Lmdl)

outlier = Lmdl.Residuals.Raw <-10;
outlier = find(outlier) ;

%% Remove outlier :   

Lmdl = fitlm(training(:, [features, target]),'Exclude',outlier);

Lmdl.ObservationInfo(outlier,:)

%%
%{
%% Simplify the model
mdl1 = step(mdl,'NSteps',10)
plotResiduals(mdl1)

% the result is a model that use only one module as predictor ..
%the one whith the lowest pValue
%} 

%% Predict responses to test data

% feval and Predict are similar 
% unlike predict, feval does not give confidence intervals on its predictions 
% feval simpler and only pring the predicted value 

% testing(:,[features])
% test = [75 78 98 80;50 60 55 45];
% new = feval(mdl,testing(:,[features]));

%ypred >> predicted value , yci >> confidence intervals 

%% test the model using the testing set 
[ypred,yci] = predict(Lmdl,testing(:,[features, target]));

%%
plot(testing{:,target}, ypred,'x');
title(sprintf('Target : %s',training.Properties.VariableNames{target})); 
xlabel('Actual Mark');
ylabel('predicted Mark');

%print(sprintf('figures/path1360_l4l5_vs_%s_Lmdl_testing',training.Properties.VariableNames{target}),'-dpng');

%% r squared 
r2=rsquared(testing{:,target}, ypred)

%% Model with Robust fitting  (better)

LmdlR = fitlm(training(indices==1, [features, target]),'RobustOpts','on');

%% test the robust model using the testing set 
[ypred,yci] = predict(LmdlR,testing(:,[features, target]));

%%
r2=rsquare(testing{:,target}, ypred)

%%
plot(testing{:,target}, ypred,'x');
title(sprintf('Target : %s',training.Properties.VariableNames{target})); 
xlabel('Actual Mark');
ylabel('predicted Mark');

print(sprintf('figures/path1360_l4l5_vs_%s_testing_robust',training.Properties.VariableNames{target}),'-dpng');


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2# Regression decision tree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
Rtree = fitrtree(training(:,features),training(:,target));

%%
yfit= predict(Rtree,testing(:,[features, target]));

%% r2 is actually nigative ??
r2=rsquare(testing.m2002, yfit)
r2=rsquared(testing.m2002, yfit)

%% 
resuberror = resubLoss(Rtree)
%%
view(Rtree,'Mode','graph')
%%
plot(testing{:,target}, yfit,'x');
title(sprintf('Target : %s',training.Properties.VariableNames{target})); 
xlabel('Actual Mark');
ylabel('predicted Mark');

%print(sprintf('figures/path1360_l4l5_vs_%s_testing_Rtree',training.Properties.VariableNames{target}),'-dpng');


%%
cvRtree = crossval(Rtree)
cvloss = kfoldLoss(cvRtree)

%%

numBranches = @(x)sum(x.IsBranch);
mdlDefaultNumSplits = cellfun(numBranches, cvRtree.Trained);

figure;
histogram(mdlDefaultNumSplits)

%%
view(cvRtree.Trained{1},'Mode','graph')

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3# Partial least-squares regression PLSR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
