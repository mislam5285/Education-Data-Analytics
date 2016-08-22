%-------------------------------------------------%
%  H1-H2: Neural Network - nonlinear Regression   %
%               P ( l5 moduel | l4 )              %
%-------------------------------------------------%

%%
load main_sara.mat academic sortedPath;

%% top paths ( min 40 student )

pathlist=table2cell(sortedPath(1:2,1));

%%
h1_NN_l5  = cell2table(cell(0,11), 'VariableNames',...
    {'PathCode', 'StudentNum', 'TrainingNum', 'PredictorsNum', 'Target',...
     'R2', 'MSE', 'RMSE','PredR2','PredMSE', 'PredRMSE'});

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
     [trainInd,ValidInd,testInd] = dividerand(size(pathRecords,1),5,2,3);
     
     trainFcn = 'trainlm';
     
     for t = 1:yc-1
         hrecords= zeros(xc-1,4);
         for h = 1:xc-1 % loop through range of different hidden layer sizes (no greater than the number of predictors) 
             
             % Creat a model
             clear net;
             net = fitnet(h,trainFcn);
             
             trials=zeros(10,3);
             for Ntrials = 1 : 10 % random weight initializations for each h
                 
                 % rng('default');
                 % train the model
                 [net,tr] = train(net,X(trainInd,:)',Y(trainInd,t)');
                 
                 % Test the model using the validate set
                 VY = net(X(ValidInd,:)');
                 
                 MSE = perform(net,Y(ValidInd,t)',VY);
                 RMSE = sqrt(MSE);
                 R2 = rsquared(Y(ValidInd,t)',VY);
                 trials(Ntrials,:) = [ MSE, RMSE, R2];
             end
             
             hrecords(h,:) = [h mean(trials,1)];  % record h size and the mean of MSE & R2 for the 10 random weight initializations
         end
         
         % choose based on the lower MSE
         [~, idx] = min(hrecords(:,2));
         bestH = hrecords(idx,1);
         
         % create the model with the optimal H
         clear net tr;
         net = fitnet(bestH,trainFcn);
         
         % train the model
         [net,tr,trainY ,e] = train(net,X(trainInd,:)',Y(trainInd,t)');
         
         % test the model using the testing set
         TestY = net(X(testInd,:)');
         
         
         % Record every itration information
         PathCode = pathlist{p};
         StudentNum = size(pathRecords,1);
         TrainingNum = numel(trainInd);
         PredictorsNum = xc-1;
         Target = l5m.Properties.VariableNames{t};
         % training
         % http://uk.mathworks.com/matlabcentral/answers/51082#comment_173981
         y00 =  repmat(mean(Y(trainInd,t)',2),1,numel(trainInd));
         e00 =  Y(trainInd,t)'-y00;
         MSE00 = mse(e00);
         %
         
         %MEANe = mean(e);
         MSE   = mse(e);
         RMSE = sqrt(MSE);
         NMSE  = MSE/MSE00 ;       % Normalized MSE
         R2    = 1-NMSE     ;  % R
         %R     = sqrt(R2) ;
         
         % testing
         PredMSE = perform(net,Y(testInd,t)',TestY);
         PredRMSE = sqrt(MSE);
         PredR2 = rsquared(Y(testInd,t)',TestY);
         
         temp_ = cell2table({ PathCode, StudentNum, TrainingNum, PredictorsNum, ...
             Target,R2, MSE, RMSE, PredR2, PredMSE, PredRMSE },'VariableNames', {'PathCode', ...
             'StudentNum', 'TrainingNum', 'PredictorsNum', 'Target',...
             'R2', 'MSE', 'RMSE','PredR2','PredMSE', 'PredRMSE'});
         
         h1_NN_l5 = [h1_NN_l5; temp_];
         
     end
     %sprintf('%d : Path : %s DONE',p,pathlist{p})
 end

 %%
 % Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotfit(net,x,t)

%%
clear PathCode StudentNum TrainingNum PredictorsNum Target RMSE
clear MSE R2 AdjR2 PredR2 PredMSE PredRMSE ResponseRate ypred temp_ 
clear p t trainInd testInd ValidInd MSE00 net tr R y
clear pathRecords l4m l5m VY TestY trainY y00 trials trainFcn Ntrials NMSE MEANe e e00
clear xr xc yr yc X Y f i m idx hrecords bestH h filename 