%% Neural network fitting
target_ = table2array(path1360(:,target));
edges_ =  [0 40 60 70 100];
target_ = discretize(target_, edges_); %{'F','P','M', 'D'});

ds = path1360;
ds.MarkClass=target_; 

train_X_ = table2array(ds(trainInd,features));
train_Y_ = table2array(ds(trainInd,{'MarkClass'}));

test_X_ = table2array(ds(testInd,features));
teat_Y_ = table2array(ds(testInd,{'MarkClass'}));