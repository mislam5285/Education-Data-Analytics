load main_sara.mat academic sortedPath;

%---------------------------%
%  LINEAR Regression model  %
%  P ( l5 moduel | l4 )     %
%---------------------------%

%% top paths ( min 40 student )

pathlist=table2cell(sortedPath(1:23,1));

%%
h2_Lmdl_l5  = cell2table(cell(0,11), 'VariableNames',...
    {'PathCode', 'StudentNum', 'TrainingNum', 'PredictorsNum','Predictors' ,'Target',...
    'RMSE', 'MSE', 'R2', 'AdjR2', 'PredR2'});

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
        
        for k = 1:xc-1
            clear m
            m = nchoosek([1:xc-1],k);
            
            for i = 1:size(m,1)
                input = m(i,:);
                
                % Creat a model
                clear Lmdl;
                Lmdl = fitlm(X(trainInd,input),Y(trainInd,t));
                
                % Test the model
                ypred = predict(Lmdl,X(testInd,input));
                
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
                
                Predictors = l4m.Properties.VariableNames(input);
                Predictors = strcat(Predictors,{' '});
                Predictors = cell2mat(Predictors);
                Predictors = strtrim(Predictors);
                
                temp_ = cell2table({ PathCode, StudentNum, TrainingNum, PredictorsNum, ...
                    Predictors, Target, RMSE, MSE, R2 AdjR2, PredR2 },'VariableNames', {'PathCode', ...
                    'StudentNum', 'TrainingNum', 'PredictorsNum','Predictors','Target','RMSE',...
                    'MSE', 'R2', 'AdjR2', 'PredR2'});
                
                h2_Lmdl_l5 = [h2_Lmdl_l5; temp_];
               % plotting takes very long time and generats figures
                %{
                % Plot the real and the predicted Y of the testing set
                f = figure('visible', 'off');
                plot(Y(testInd,t), ypred,'x');
                title(sprintf('Path : %s Target : %s\n\n Response rate: %1.3f | R-squared: %1.3f\n\n Predictors Number: %d | Predictors Names: %s',...
                    pathlist{p}, l5m.Properties.VariableNames{t}, ResponseRate, PredR2, PredictorsNum, Predictors));
                xlabel('Actual Mark');
                ylabel('predicted Mark');
                print(sprintf('figures/p_h2_l5_path%s_%s_%s_%s',pathlist{p},l5m.Properties.VariableNames{t},num2str(k),num2str(i)),'-dpng');
                close(f)
                %}
                
            end
        end
    end
end

%% plot X: number of predictors Y: R-squared
plot(h2_Lmdl_l5.PredictorsNum,h2_Lmdl_l5.R2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Linear Regression Model R-Squared Values Against Number Of Predictors \n')); 
xlabel('Number Of Predictors');
ylabel('R-squared');
print('figures/p_l5_R2_vs_PredictorsNum','-dpng');

%% plot X: number of predictors Y: Predicted R-squared
plot(h2_Lmdl_l5.PredictorsNum,h2_Lmdl_l5.PredR2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Predicted R-Squared Values Against Number Of Predictors \n')); 
xlabel('Number Of Predictors');
ylabel('Predicted R-squared');
print('figures/p_l5_PredR2_vs_PredictorsNum','-dpng');

%% %% plot X: Number of Training observations Y: R-squared
plot(h2_Lmdl_l5.TrainingNum,h2_Lmdl_l5.R2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Linear Regression Model R-Squared Values Against Number of Training Observations \n')); 
xlabel('Number of Training Observations');
ylabel('R-squared');
print('figures/p_l5_R2_vs_TrainingNum','-dpng');

%% %% plot X: Number of Training observations Y: Predicted R-squared
plot(h2_Lmdl_l5.TrainingNum,h2_Lmdl_l5.PredR2,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Plot Predicted R-Squared Values Against Number of Training Observations \n')); 
xlabel('Number of Training Observations');
ylabel('Predicted R-squared');
print('figures/p_l5_PredR2_vs_TrainingNum','-dpng');

%% Use the mean for path
Lmdl_l5_mean=grpstats(h2_Lmdl_l5,{'PathCode','StudentNum','TrainingNum','PredictorsNum'}, {'mean'} ,'DataVars',{'RMSE','MSE','R2','AdjR2','PredR2'});
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
filename = 'h2_Lmdl_L5.csv';
writetable(h2_Lmdl_l5,filename);
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
