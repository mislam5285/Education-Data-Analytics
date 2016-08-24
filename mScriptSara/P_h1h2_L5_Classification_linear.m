
%-------------------------------------------%
%    H1-H2: Linear - Classification model   %
%            P ( l5 moduel | l4 )           %
%-------------------------------------------%

%%
load main_modelling.mat academic sortedPath;

%% top paths ( min 40 student )

pathlist=table2cell(sortedPath(1:23,1));

%%
h1_CLmnr_l5  = cell2table(cell(0,7), 'VariableNames',...
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
    [trainInd,~,testInd] = dividerand(size(pathRecords,1),7,0,3);
    
    for t = 1:yc-1
        
        % Creat a model
        
        %[mnr,dev,stats]
        mnr = mnrfit(X(trainInd,:),Y(trainInd,t),'Model','ordinal');
        
        % Test the model
        pihat = mnrval(mnr,X(testInd,:),'Model','ordinal');
        [~,idx]=max(pihat,[],2);
        
        % Record every itration information
        PathCode = pathlist{p};
        StudentNum = size(pathRecords,1);
        TrainingNum = size(X(trainInd,:),1);
        PredictorsNum = xc-1;
        Target = l5m.Properties.VariableNames{t};
        [Accuracy, Error, ResponseRate]=AccuracyRate(Y(testInd,t),idx);
        
        
        temp_ = cell2table({ PathCode, StudentNum, TrainingNum, PredictorsNum, ...
            Target, Accuracy, Error },'VariableNames', {'PathCode', ...
            'StudentNum', 'TrainingNum', 'PredictorsNum', 'Target',...
            'Accuracy', 'Error'});
        
        h1_CLmnr_l5 = [h1_CLmnr_l5; temp_];
        
        % sprintf('Path : %s Target : %s',pathlist{p}, l5m.Properties.VariableNames{t})
    end
    %sprintf('%d : Path : %s DONE',p,pathlist{p})
end


%%
plot(h1_CLmnr_l5.TrainingNum,h1_CLmnr_l5.Accuracy,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Multinomial Logistic Regression \n')); 
xlabel('Number Of Trining Observation');
ylabel('Prediction Accuracy ');
print('figures/p_l5_mnr__vs_TrainingNum','-dpng');
%plot(h1_CLmnr_l5.TrainingNum,h1_CLmnr_l5.Error,'.')
%%
plot(h1_CLmnr_l5.PredictorsNum,h1_CLmnr_l5.Accuracy,'mx','MarkerSize',7)
%%plot(h1_CLmnr_l5.PredictorsNum,h1_CLmnr_l5.Error,'.')
title(sprintf('P(L5 module|L4 modules)\n\n Multinomial Logistic Regression \n')); 
xlabel('Number Of Predictors');
ylabel('Prediction Accuracy');
print('figures/p_l5_mnr_Accuracy_vs_PredictorsNum_mean','-dpng');

%% Use the mean for path
h1_CLmnr_l5_mean=grpstats(h1_CLmnr_l5,{'PathCode','StudentNum','TrainingNum','PredictorsNum'}, {'mean'} ,'DataVars',{'Accuracy', 'Error'});
h1_CLmnr_l5_mean(:,5)=[];
%%
plot(h1_CLmnr_l5_mean.PredictorsNum,h1_CLmnr_l5_mean.mean_Accuracy,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Multinomial Logistic Regression \n')); 
xlabel('Number Of Predictors');
ylabel('Prediction Accuracy (mean)');
print('figures/p_l5_mnr_Accuracy_vs_PredictorsNum_mean','-dpng');
%%
plot(h1_CLmnr_l5_mean.TrainingNum,h1_CLmnr_l5_mean.mean_Accuracy,'mx','MarkerSize',7)
title(sprintf('P(L5 module|L4 modules)\n\n Multinomial Logistic Regression \n')); 
xlabel('Number Of Trining Observation');
ylabel('Prediction Accuracy (mean)');
print('figures/p_l5_mnr__vs_TrainingNum_mean','-dpng');

%% Export to Excel
filename = 'h1_CLmnr_l5.csv';
writetable(h1_CLmnr_l5,filename);
%%
filename = 'h1_CLmnr_l5_mean.csv';
writetable(h1_CLmnr_l5_mean,filename);
%%
clear PathCode StudentNum TrainingNum PredictorsNum Target
clear Accuracy Error ResponseRate temp_
clear p t trainInd testInd ValidInd validlabel pihat
clear pathRecords l4m l5m dev stats mnr
clear xr xc yr yc X Y f m pl idx ar filename
%%
save main_modelling.mat Lmdl_L5 Lmdl_L5_mean
