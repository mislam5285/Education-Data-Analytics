
%----------------------------------------------%
%    H1-H2: NonLinear - Classification model   %
%            P ( l5 moduel | l4 )              %
%----------------------------------------------%

%%
load main_sara.mat academic sortedPath;

%% top paths ( min 40 student )

pathlist=table2cell(sortedPath(1:23,1));

%%
h1_Ctree_l5  = cell2table(cell(0,7), 'VariableNames',...
    {'PathCode', 'StudentNum', 'TrainingNum', 'PredictorsNum', 'Target',...
    'Accuracy', 'Error'});

%% 1 - P(L5|L4) Predicate student L5 performance based on L4 performance

for p = 1:length(pathlist)
    pathRecords = academic(academic.PathCode == pathlist{p},:); 
    [pathRecords, l4m, l5m]= processPathRecords2(pathRecords); %prepare the data
    
    %
    [xr, xc] = size(l4m);
    X = table2array(l4m(:,1:xc-1));      % last column is the student id
    [yr, yc] = size(l5m);
    Y = table2array(l5m(:,1:yc-1));
    
    
   % Discretize the mark value for the classification 
    edges_ =  [0 40 60 70 100];
    Y = discretize(Y, edges_); % 'categorical',{'F','P','M','D'}); 
    % F=1, P=2, M=3, D=4
    
    %
    rng('default');
    [trainInd,ValidInd,testInd] = dividerand(size(pathRecords,1),5,2,3);
    
    for t = 1:yc-1
        
       % Creat a model  
       clear ctree;
       ctree = fitctree(X(trainInd,:),Y(trainInd,t),...
           'PredictorNames',l4m.Properties.VariableNames(1:xc-1),...
           'ResponseName',l5m.Properties.VariableNames{t});
       %'CrossVal','on','KFold',5
       %Warning: One or more folds do not contain points from all the groups.
        
       % prune the tree according to the best accuracy level
       
       pl = ctree.PruneList;
       ar = zeros(numel(pl),1);
       
       for m=1:length(ctree.PruneList)
           ctree1 = prune(ctree,'Level', pl(m));
           validlabel = predict(ctree1,X(ValidInd,:));
           ar(m) = AccuracyRate(Y(ValidInd,t), validlabel); 
           clear ctree1
       end;
       
       [~, idx] = max(ar);
       ctree = prune(ctree,'Level',pl(idx));
       
       % Test the model
       label = predict(ctree,X(testInd,:));
       
       % Record every itration information
       PathCode = pathlist{p};
       StudentNum = size(pathRecords,1);
       TrainingNum = ctree.NumObservations;
       PredictorsNum = xc-1;
       Target = ctree.ResponseName;
       [Accuracy, Error, ResponseRate] = AccuracyRate(Y(testInd,t), label);
       
              
       temp_ = cell2table({ PathCode, StudentNum, TrainingNum, PredictorsNum, ...
       Target, Accuracy, Error },'VariableNames', {'PathCode', ...
       'StudentNum', 'TrainingNum', 'PredictorsNum', 'Target',...
       'Accuracy', 'Error'});
   
       h1_Ctree_l5 = [h1_Ctree_l5; temp_];

      % sprintf('Path : %s Target : %s',pathlist{p}, l5m.Properties.VariableNames{t})
    end
    %sprintf('%d : Path : %s DONE',p,pathlist{p})
end

%% plot X: number of predictors Y: R-squared
plot(h1_Ctree_l5.PredictorsNum,h1_Ctree_l5.R2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Linear Regression Model R-Squared Values Against Number Of Predictors \n')); 
xlabel('Number Of Predictors');
ylabel('R-squared');
print('figures/p_l5_R2_vs_PredictorsNum','-dpng');
%%
plot(h1_Ctree_l5.TrainingNum,h1_Ctree_l5.Accuracy,'.')
plot(h1_Ctree_l5.TrainingNum,h1_Ctree_l5.Error,'.')
plot(h1_Ctree_l5.PredictorsNum,h1_Ctree_l5.Accuracy,'.')
plot(h1_Ctree_l5.PredictorsNum,h1_Ctree_l5.Error,'.')

%% Use the mean for path
h1_Ctree_l5_mean=grpstats(h1_Ctree_l5,{'PathCode','StudentNum','TrainingNum','PredictorsNum'}, {'mean'} ,'DataVars',{'Accuracy', 'Error'});
h1_Ctree_l5_mean(:,5)=[];

%%
plot(h1_Ctree_l5_mean.TrainingNum,h1_Ctree_l5_mean.mean_Accuracy,'.')
plot(h1_Ctree_l5_mean.PredictorsNum,h1_Ctree_l5_mean.mean_Accuracy,'.')

%% Export to Excel 
filename = 'h1_Ctree_l5.csv';
writetable(h1_Ctree_l5,filename);
%%
filename = 'h1_Ctree_l5_mean.csv';
writetable(h1_Ctree_l5_mean,filename);
%%
clear PathCode StudentNum TrainingNum PredictorsNum Target 
clear Accuracy Error ResponseRate temp_
clear p t trainInd testInd ValidInd validlabel label
clear pathRecords l4m l5m mList
clear xr xc yr yc X Y f m pl idx ar filename 
%% 
save main_modelling.mat Lmdl_L5 Lmdl_L5_mean 
