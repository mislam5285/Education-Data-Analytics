%% load the data
load main_sara_data.mat store student;

%% find pairs of modules taken by the same students

%http://uk.mathworks.com/help/matlab/ref/containers.map-class.html
%http://uk.mathworks.com/help/matlab/ref/sparse.html#bul62_1


codelist=unique(dat.key); %module list
idlist=unique(dat.id); %student list
mapObj = containers.Map(codelist,1:numel(codelist));
idObj = containers.Map(idlist,1:numel(idlist));
%% create the sparse matrix

row=cell2mat(values(idObj,num2cell(dat.id)));
col=cell2mat(values(mapObj,dat.key));
mat=sparse(row, col,dat.count,numel(keys(idObj)), numel(keys(mapObj)));
