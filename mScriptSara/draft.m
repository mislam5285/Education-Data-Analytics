%%
 
Lmdl_l5_mean=grpstats(Lmdl_l5,{'PathCode','StudentNum','TrainingNum','PredictorsNum'}, {'mean'} ,'DataVars',{'RMSE','MSE','R2','AdjR2','PredR2'});
Lmdl_l5_mean(:,5)=[];

%% plot X: number of predictors Y: R-squared (mean 
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