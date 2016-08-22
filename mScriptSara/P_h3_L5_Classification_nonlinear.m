
%-------------------------------------------%
%    H3: NonLinear - Classification model   %
%          P ( l5 moduel | l4 )             %
%-------------------------------------------%

%%
load main_sara.mat academic sortedPath;

%% top paths ( min 40 student )

pathlist=table2cell(sortedPath(1:23,1));

%%
h3_Ctree_l5  = cell2table(cell(0,8), 'VariableNames',...
    {'PathCode', 'StudentNum', 'TrainingNum', 'PredictorsNum', 'Target',...
    'Predictors','Accuracy', 'Error'});

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
        %sprintf('enter l2 loop(target) t: %d',t)
        for k = 1:xc-1
         %   sprintf('enter l3 loop (nchoose) k: %d',k)
            clear m
            m = nchoosek([1:xc-1],k);
            
            for i = 1:size(m,1)
          %       sprintf('enter inner loop (prediction) i: %d',i)
                input = m(i,:);
                
                % Creat a model
                clear ctree;
                ctree = fitctree(X(trainInd,input),Y(trainInd,t),...
                    'PredictorNames',l4m.Properties.VariableNames(input),...
                    'ResponseName',l5m.Properties.VariableNames{t});
                %'CrossVal','on','KFold',5
                %Warning: One or more folds do not contain points from all the groups.
                
                % prune the tree according to the best accuracy level
                
                pl = ctree.PruneList;
                ar = zeros(numel(pl),1);
                
                for a=1:length(ctree.PruneList)
                    sprintf('enter prune loop  m: %d',a)
                    ctree1 = prune(ctree,'Level', pl(a));
                    validlabel = predict(ctree1,X(ValidInd,input));
                    ar(a) = AccuracyRate(Y(ValidInd,t), validlabel);
                    clear ctree1
                end;
                
                [~, idx] = max(ar);
                ctree = prune(ctree,'Level',pl(idx));
                
                % Test the model
                label = predict(ctree,X(testInd,input));
                
                % Record every itration information
                PathCode = pathlist{p};
                StudentNum = size(pathRecords,1);
                TrainingNum = ctree.NumObservations;
                PredictorsNum = numel(input);
                Target = ctree.ResponseName;
                [Accuracy, Error, ResponseRate] = AccuracyRate(Y(testInd,t), label);
                
                Predictors = l4m.Properties.VariableNames(input);
                Predictors = strcat(Predictors,{' '});
                Predictors = cell2mat(Predictors);
                Predictors = strtrim(Predictors);
                
                temp_ = cell2table({ PathCode, StudentNum, TrainingNum, PredictorsNum, ...
                    Predictors,Target, Accuracy, Error },'VariableNames', {'PathCode', ...
                    'StudentNum', 'TrainingNum', 'PredictorsNum', 'Target',...
                    'Predictors','Accuracy', 'Error'});
                
                h3_Ctree_l5 = [h3_Ctree_l5; temp_];
                
                % sprintf('Path : %s Target : %s',pathlist{p}, l5m.Properties.VariableNames{t})
            end
            %sprintf('%d : Path : %s DONE',p,pathlist{p})
        end
    end
end

%%
clear PathCode StudentNum TrainingNum PredictorsNum Target 
clear Accuracy Error ResponseRate temp_
clear p t trainInd testInd ValidInd validlabel label
clear pathRecords l4m l5m mList 
clear xr xc yr yc X Y f m pl idx ar filename 