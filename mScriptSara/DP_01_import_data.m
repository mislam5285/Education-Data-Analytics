%% Load the data
    %Creat a datastore of large dataset

    ds = datastore('data/Computing Data Request 170316.csv'); 

%% Missing Values
    % NOTE : since NaN mark is not equivelent to Zero, I commented this section until dexploring and building the model

% ds.MissingValue = 0; % Value for missing numeric fields (Mark)

%%
% To read the Nationality code{3} & Module Code{10} (which are numeric) as strings
ds.TextscanFormats{3}='%q';
ds.TextscanFormats{10}='%q';
ds.ReadSize = 141840;  % To read all rows in the dataset

%%
store = read(ds);

%%
% reset(ds);

%% Convert table variables with discrete categories to the Categorical Arrays

%% StudentIDCode
store.StudentIDCode = categorical(store.StudentIDCode);

%% NationalityCode
store.NationalityCode = categorical(store.NationalityCode);

%% GenderCode
store.GenderCode = categorical(store.GenderCode);

%% ClassificationName
store.ClassificationName = categorical(store.ClassificationName);
% create a Undfined category for missing values
store.ClassificationName(isundefined(store.ClassificationName)) = 'Undefined';

%% NQFNAME
store.NQFName = categorical(store.NQFName);

%% ReasonForTransferName
store.ReasonForTransferName = categorical(store.ReasonForTransferName);

%% ModuleCode
store.ModuleCode = categorical(store.ModuleCode);

%%
save main_sara.mat store;

