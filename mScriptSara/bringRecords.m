%% function to bring academic records of set of students 

function f= bringRecords(ID, records)
clear index_;
vars={ 'StudentIDCode','ClassificationName','NQFName','StartYear','EndYear','ReasonForTransferName','PathCode','ModuleCode','Mark','DurationAtUni'};
index_=ismember(records.StudentIDCode,ID.StudentIDCode);
f= records(index_,vars);
end