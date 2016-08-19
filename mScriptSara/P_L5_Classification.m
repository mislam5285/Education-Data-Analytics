load main_sara.mat academic sortedPath;

%----------------------------%
%    Classification model    %
%    P ( l5 moduel | l4 )    %
%----------------------------%

%% top paths ( min 40 student )

pathlist=table2cell(sortedPath(1,1));
%:23
%%
Lmdl_l5  = cell2table(cell(0,10), 'VariableNames',...
    {'PathCode', 'StudentNum', 'TrainingNum', 'PredictorsNum', 'Target',...
    'RMSE', 'MSE', 'R2', 'AdjR2', 'PredR2'});

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
    Y = discretize(Y, edges_); %{'F','P','M','D'}); % F=1, P=2, M=3, D=4
    
    %
    rng('default');
    [trainInd,~,testInd] = dividerand(size(pathRecords,1),7,0,3);
    
    for t = 1:yc-1
        
       % Creat a model  
       clear ctree;
       ctree = fitctree(X(trainInd,:),Y(trainInd,t),...
           'PredictorNames',l4m.Properties.VariableNames(1:xc-1),...
           'ResponseName',l5m.Properties.VariableNames{t});
       %'CrossVal','on','KFold',5
       %Warning: One or more folds do not contain points from all the groups.
       
       
       % Test the model
       label= predict(ctree,X(testInd,:));
       %[label,score,node,cnum] = predict(ctree,X(testInd,:));
       CP = classperf(Y(testInd,:),label);
       
       % Record every itration information
       PathCode = pathlist{p};
       StudentNum = size(pathRecords,1);
       TrainingNum = Lmdl.NumObservations;
       PredictorsNum = Lmdl.NumPredictors;
       Target = l5m.Properties.VariableNames{t};
       RMSE = Lmdl.RMSE;
       MSE = Lmdl.MSE;
       R2 = Lmdl.Rsquared.Ordinary;
       AdjR2 = Lmdl.Rsquared.Adjusted;
       [PredR2, ResponseRate] = rsquared(Y(testInd,t), ypred);
              
       temp_ = cell2table({ PathCode, StudentNum, TrainingNum, PredictorsNum, ...
       Target, RMSE, MSE, R2 AdjR2, PredR2 },'VariableNames', {'PathCode', ...
       'StudentNum', 'TrainingNum', 'PredictorsNum', 'Target','RMSE',...
       'MSE', 'R2', 'AdjR2', 'PredR2'});
   
       Lmdl_l5 = [Lmdl_l5; temp_];
       
       % Plot the real and the predicted Y of the testing set 
       f = figure('visible', 'off');
       plot(Y(testInd,t), ypred,'x');
       title(sprintf('Path : %s Target : %s\n\n Response rate: %1.3f | R-squared: %1.3f\n',pathlist{p}, l5m.Properties.VariableNames{t}, ResponseRate, PredR2)); 
       xlabel('Actual Mark');
       ylabel('predicted Mark');
       print(sprintf('figures/p_l5_path%s_%s',pathlist{p},l5m.Properties.VariableNames{t}),'-dpng');
       close(f)
       
       %
      % sprintf('Path : %s Target : %s',pathlist{p}, l5m.Properties.VariableNames{t})
    end
    %sprintf('%d : Path : %s DONE',p,pathlist{p})
end

%% plot X: number of predictors Y: R-squared
plot(Lmdl_l5.PredictorsNum,Lmdl_l5.R2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Linear Regression Model R-Squared Values Against Number Of Predictors \n')); 
xlabel('Number Of Predictors');
ylabel('R-squared');
print('figures/p_l5_R2_vs_PredictorsNum','-dpng');

%% plot X: number of predictors Y: Predicted R-squared
plot(Lmdl_l5.PredictorsNum,Lmdl_l5.PredR2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Predicted R-Squared Values Against Number Of Predictors \n')); 
xlabel('Number Of Predictors');
ylabel('Predicted R-squared');
print('figures/p_l5_PredR2_vs_PredictorsNum','-dpng');

%% %% plot X: Number of Training observations Y: R-squared
plot(Lmdl_l5.TrainingNum,Lmdl_l5.R2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Linear Regression Model R-Squared Values Against Number of Training Observations \n')); 
xlabel('Number of Training Observations');
ylabel('R-squared');
print('figures/p_l5_R2_vs_TrainingNum','-dpng');

%% %% plot X: Number of Training observations Y: Predicted R-squared
plot(Lmdl_l5.TrainingNum,Lmdl_l5.PredR2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Predicted R-Squared Values Against Number of Training Observations \n')); 
xlabel('Number of Training Observations');
ylabel('Predicted R-squared');
print('figures/p_l5_PredR2_vs_TrainingNum','-dpng');

%% Use the mean for path
Lmdl_l5_mean=grpstats(Lmdl_l5,{'PathCode','StudentNum','TrainingNum','PredictorsNum'}, {'mean'} ,'DataVars',{'RMSE','MSE','R2','AdjR2','PredR2'});
Lmdl_l5_mean(:,5)=[];

%% plot X: number of predictors Y: R-squared (mean)
plot(Lmdl_l5_mean.PredictorsNum,Lmdl_l5_mean.mean_R2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Linear Regression Model R-Squared Values Against Number Of Predictors \n')); 
xlabel('Number Of Predictors');
ylabel('R-squared');
print('figures/p_l5_R2_vs_PredictorsNum_mean','-dpng');

%% plot X: number of predictors Y: Predicted R-squared  (mean)
plot(Lmdl_l5_mean.PredictorsNum,Lmdl_l5_mean.mean_PredR2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Predicted R-Squared Values Against Number Of Predictors \n')); 
xlabel('Number Of Predictors');
ylabel('Predicted R-squared');
print('figures/p_l5_PredR2_vs_PredictorsNum_mean','-dpng');

%% %% plot X: Number of Training observations Y: R-squared  (mean)
plot(Lmdl_l5_mean.TrainingNum,Lmdl_l5_mean.mean_R2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Linear Regression Model R-Squared Values Against Number of Training Observations \n')); 
xlabel('Number of Training Observations');
ylabel('R-squared');
print('figures/p_l5_R2_vs_TrainingNum_mean','-dpng');

%% %% plot X: Number of Training observations Y: Predicted R-squared  (mean)
plot(Lmdl_l5_mean.TrainingNum,Lmdl_l5_mean.mean_PredR2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Predicted R-Squared Values Against Number of Training Observations \n')); 
xlabel('Number of Training Observations');
ylabel('Predicted R-squared');
print('figures/p_l5_PredR2_vs_TrainingNum_mean','-dpng');

%% Export to Excel 
filename = 'Lmdl_L5.csv';
writetable(Lmdl_l5,filename);
%%
filename = 'Lmdl_L5_mean.csv';
writetable(Lmdl_l5_mean,filename);
%%
clear PathCode StudentNum TrainingNum PredictorsNum Target RMSE
clear MSE R2 AdjR2 PredR2 ResponseRate ypred temp_
clear p t trainInd testInd
clear pathRecords l4m l5m
clear xr xc yr yc X Y f filename
%% 
save main_modelling.mat
