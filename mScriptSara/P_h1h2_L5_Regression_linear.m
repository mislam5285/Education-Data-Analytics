
%----------------------------------%
%  H1-H2: LINEAR Regression model  %
%       P ( l5 moduel | l4 )       %
%----------------------------------%

%%
load main_sara.mat academic sortedPath;

%% top paths ( min 40 student )

pathlist=table2cell(sortedPath(1:23,1));

%%
h1_Lmdl_l5  = cell2table(cell(0,12), 'VariableNames',...
    {'PathCode', 'StudentNum', 'TrainingNum', 'PredictorsNum', 'Target',...
    'RMSE', 'MSE', 'R2', 'AdjR2', 'PredR2','PredMSE', 'PredRMSE'});

%% 1 - P(L5|L4) Predicate student L5 performance based on L4 performance

for p = 1:length(pathlist)
    pathRecords = academic(academic.PathCode == pathlist{p},:); 
    [pathRecords, l4m, l5m]= processPathRecords2(pathRecords); %prepare the data
    
    [xr, xc] = size(l4m);
    X = table2array(l4m(:,1:xc-1));      % last column is the student id
    [yr, yc] = size(l5m);
    Y = table2array(l5m(:,1:yc-1));
    
    %
    rng('default');
    [trainInd,~,testInd] = dividerand(size(pathRecords,1),7,0,3);
    
    for t = 1:yc-1
        
       % Creat a model  
       clear Lmdl;
       Lmdl = fitlm(X(trainInd,:),Y(trainInd,t));
       
       % Test the model
       ypred = predict(Lmdl,X(testInd,:));
       
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
       [PredR2, ResponseRate,PredMSE, PredRMSE] = rsquared(Y(testInd,t), ypred);
              
       temp_ = cell2table({ PathCode, StudentNum, TrainingNum, PredictorsNum, ...
       Target, RMSE, MSE, R2, AdjR2, PredR2, PredMSE, PredRMSE },'VariableNames', {'PathCode', ...
       'StudentNum', 'TrainingNum', 'PredictorsNum', 'Target','RMSE',...
       'MSE', 'R2', 'AdjR2', 'PredR2','PredMSE', 'PredRMSE'});
   
       h1_Lmdl_l5 = [h1_Lmdl_l5; temp_];
       %{
       % Plot the real and the predicted Y of the testing set 
       f = figure('visible', 'off');
       plot(Y(testInd,t), ypred,'x');
       title(sprintf('Path : %s Target : %s\n\n Response rate: %1.3f | R-squared: %1.3f\n',pathlist{p}, l5m.Properties.VariableNames{t}, ResponseRate, PredR2)); 
       xlabel('Actual Mark');
       ylabel('predicted Mark');
       print(sprintf('figures/p_l5_path%s_%s',pathlist{p},l5m.Properties.VariableNames{t}),'-dpng');
       close(f)
       %}
       %
      % sprintf('Path : %s Target : %s',pathlist{p}, l5m.Properties.VariableNames{t})
    end
    %sprintf('%d : Path : %s DONE',p,pathlist{p})
end

%% plot X: number of predictors Y: R-squared
plot(h1_Lmdl_l5.PredictorsNum,h1_Lmdl_l5.R2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Linear Regression Model R-Squared Values Against Number Of Predictors \n')); 
xlabel('Number Of Predictors');
ylabel('R-squared');
print('figures/p_l5_R2_vs_PredictorsNum','-dpng');

%% plot X: number of predictors Y: Predicted R-squared
plot(h1_Lmdl_l5.PredictorsNum,h1_Lmdl_l5.PredR2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Predicted R-Squared Values Against Number Of Predictors \n')); 
xlabel('Number Of Predictors');
ylabel('Predicted R-squared');
print('figures/p_l5_PredR2_vs_PredictorsNum','-dpng');

%% %% plot X: Number of Training observations Y: R-squared
plot(h1_Lmdl_l5.TrainingNum,h1_Lmdl_l5.R2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Linear Regression Model R-Squared Values Against Number of Training Observations \n')); 
xlabel('Number of Training Observations');
ylabel('R-squared');
print('figures/p_l5_R2_vs_TrainingNum','-dpng');

%% %% plot X: Number of Training observations Y: Predicted R-squared
plot(h1_Lmdl_l5.TrainingNum,h1_Lmdl_l5.PredR2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Predicted R-Squared Values Against Number of Training Observations \n')); 
xlabel('Number of Training Observations');
ylabel('Predicted R-squared');
print('figures/p_l5_PredR2_vs_TrainingNum','-dpng');

%%
histfit(h1_Lmdl_l5.RMSE);
title(sprintf('P(L5 module|L4 modules)\n\n Root Mean Square Error for Training set \n')); 
print('figures/p_l5_RMSE','-dpng');
%%
histfit(h1_Lmdl_l5.PredRMSE);
title(sprintf('P(L5 module|L4 modules)\n\n Root Mean Square Error for Training set \n')); 
print('figures/p_l5_PredRMSE','-dpng');

%%
scatterhist(h1_Lmdl_l5.RMSE,h1_Lmdl_l5.PredRMSE)
title(sprintf('P(L5 module|L4 modules)\n\n Comparing the training RMSE and the testing RMSE \n')); 
xlabel('Training RMSE');
ylabel('Testing RMSE');
print('figures/p_l5_RMSE_Training_VS_Testing','-dpng');

%%
scatterhist(h1_Lmdl_l5.R2,h1_Lmdl_l5.PredR2)
title(sprintf('P(L5 module|L4 modules)\n\n Comparing the training R2 and the testing R2 \n')); 
xlabel('Training RMSE');
ylabel('Testing RMSE');
print('figures/p_l5_R2_Training_VS_Testing','-dpng');

%% Use the mean for path
h1_Lmdl_l5_mean=grpstats(h1_Lmdl_l5,{'PathCode','StudentNum','TrainingNum','PredictorsNum'}, {'mean'} ,'DataVars',{'RMSE','MSE','R2','AdjR2','PredR2','PredMSE', 'PredRMSE'});
h1_Lmdl_l5_mean(:,5)=[];

%% plot X: number of predictors Y: R-squared (mean)
plot(h1_Lmdl_l5_mean.PredictorsNum,h1_Lmdl_l5_mean.mean_R2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Linear Regression Model R-Squared Values (mean) Against Number Of Predictors \n')); 
xlabel('Number Of Predictors');
ylabel('R-squared');
print('figures/p_l5_R2_vs_PredictorsNum_mean','-dpng');

%% plot X: number of predictors Y: Predicted R-squared  (mean)
plot(h1_Lmdl_l5_mean.PredictorsNum,h1_Lmdl_l5_mean.mean_PredR2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Predicted R-Squared Values (mean) Against Number Of Predictors \n')); 
xlabel('Number Of Predictors');
ylabel('Predicted R-squared');
print('figures/p_l5_PredR2_vs_PredictorsNum_mean','-dpng');

%% %% plot X: Number of Training observations Y: R-squared  (mean)
plot(h1_Lmdl_l5_mean.TrainingNum,h1_Lmdl_l5_mean.mean_R2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Linear Regression Model R-Squared Values (mean) Against Number of Training Observations \n')); 
xlabel('Number of Training Observations');
ylabel('R-squared');
print('figures/p_l5_R2_vs_TrainingNum_mean','-dpng');

%% %% plot X: Number of Training observations Y: Predicted R-squared  (mean)
plot(h1_Lmdl_l5_mean.TrainingNum,h1_Lmdl_l5_mean.mean_PredR2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Predicted R-Squared Values (mean) Against Number of Training Observations \n')); 
xlabel('Number of Training Observations');
ylabel('Predicted R-squared');
print('figures/p_l5_PredR2_vs_TrainingNum_mean','-dpng');

%%
histfit(h1_Lmdl_l5_mean.mean_RMSE);
title(sprintf('P(L5 module|L4 modules)\n\n Root Mean Square Error for Training set (mean) \n')); 
print('figures/p_l5_RMSE_mean','-dpng');
%%
histfit(h1_Lmdl_l5_mean.mean_PredRMSE);
title(sprintf('P(L5 module|L4 modules)\n\n Root Mean Square Error for Training set (mean)\n')); 
print('figures/p_l5_PredRMSE_mean','-dpng');

%%
scatterhist(h1_Lmdl_l5_mean.mean_RMSE, h1_Lmdl_l5_mean.mean_PredRMSE)
title(sprintf('P(L5 module|L4 modules)\n\n Comparing the training RMSE and the testing RMSE (mean)\n')); 
xlabel('Training RMSE');
ylabel('Testing RMSE');
print('figures/p_l5_RMSE_Training_VS_Testing_mean','-dpng');

%%
scatterhist(h1_Lmdl_l5_mean.mean_R2, h1_Lmdl_l5_mean.mean_PredR2)
title(sprintf('P(L5 module|L4 modules)\n\n Comparing the training R2 and the testing R2 (mean)\n')); 
xlabel('Training RMSE');
ylabel('Testing RMSE');
print('figures/p_l5_R2_Training_VS_Testing_mean','-dpng');

%% Export to Excel 
filename = 'h1_Lmdl_L5.csv';
writetable(h1_Lmdl_l5,filename);
%%
filename = 'h1_Lmdl_L5_mean.csv';
writetable(h1_Lmdl_l5_mean,filename);
%%
clear PathCode StudentNum TrainingNum PredictorsNum Target RMSE
clear MSE R2 AdjR2 PredR2 ResponseRate ypred temp_ 
clear p t trainInd testInd
clear pathRecords l4m l5m PredMSE PredRMSE
clear xr xc yr yc X Y f filename
%% 
save main_modelling.mat

